
/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START storage_create_pubsub_notifications_tf]
// Create a Pub/Sub notification.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.41.0"
    }
  }
}

#note about terraform google provider authentication
  #reference link: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication
  #if run terraform on your workstation (your pc)
  #if we use user application default credential (adc), we do not need to use service-account key
provider "google" {
  # credentials = file("../terraform/terraform_personal.json")

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

############################bucket config
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

#create source bucket, do not use uniform_bucket_level_access to true, use default value (false). So that we hav acl permission control
resource "google_storage_bucket" "source_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-test-source" # Every bucket name must be globally unique
  location                    = var.region
}

#create dest bucket
resource "google_storage_bucket" "dest_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-test-dest" # Every bucket name must be globally unique
  location                    = var.region
}
#grant acl owner for dataflow workder service account
resource "google_storage_bucket_acl" "dest_bucket_acl" {
  bucket = google_storage_bucket.dest_bucket.name
  #you need to specify entity type. In this case user. reference: https://cloud.google.com/storage/docs/json_api/v1/bucketAccessControls
  role_entity = [
    "OWNER:user-${var.worker_sa}",
  ]
}

#create templates buckets
resource "google_storage_bucket" "templates_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-test-dataflow-templates" # Every bucket name must be globally unique
  location                    = var.region
}

resource "google_storage_bucket_acl" "templates_bucket_acl" {
  bucket = google_storage_bucket.templates_bucket.name

  role_entity = [
    "OWNER:user-${var.worker_sa}",
  ]
}

resource "google_storage_bucket" "temp_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-test-dataflow-temp" # Every bucket name must be globally unique
  location                    = var.region
}

resource "google_storage_bucket_acl" "temp_bucket_acl" {
  bucket = google_storage_bucket.temp_bucket.name

  role_entity = [
    "OWNER:user-${var.worker_sa}",
  ]
}

resource "google_storage_bucket" "stagging_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-test-dataflow-stagging" # Every bucket name must be globally unique
  location                    = var.region
}

resource "google_storage_bucket_acl" "stagging_bucket_acl" {
  bucket = google_storage_bucket.stagging_bucket.name

  role_entity = [
    "OWNER:user-${var.worker_sa}",
  ]
}


#upload source code to a bucket
resource "google_storage_bucket_object" "object" {
  name   = "test_cloud_function.zip"
  bucket = google_storage_bucket.source_bucket.name
  source = var.python_source
}

#create bucket which will trigger cloud function
resource "google_storage_bucket" "trigger_bucket" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-trigger-bucket"
  location                    = var.region
}

resource "google_storage_bucket_acl" "trigger_bucket_acl" {
  bucket = google_storage_bucket.trigger_bucket.name

  role_entity = [
    "OWNER:user-${var.worker_sa}",
  ]
}

#dataflow flex template
data "google_storage_bucket_object" "dataflow_template" {
  name   = "dataflow_test.json"
  bucket = google_storage_bucket.templates_bucket.name
} 
############################################service account and role binding config
#get special service account of cloud storage
data "google_storage_project_service_account" "gcs_account" {
}

#get project information
data "google_project" "project" {
}

#binding publisher role for cloud storage service account at project level
resource "google_project_iam_member" "gcs_pubsub_publishing" {
  project = data.google_project.project.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

#create service account with id gcf-sa for cloud function and eventarc
resource "google_service_account" "account" {
  account_id   = "gcf-sa"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger in the test"
}

# grant role to member with google_project_iam_member
# depend_on means we need other role-binding before this one
# binding gcf-sa service account to role:
#roles/run.invoker
#roles/eventarc.eventReceiver
#roles/artifactregistry.reader
resource "google_project_iam_member" "invoking" {
  project    = data.google_project.project.project_id
  role       = "roles/run.invoker"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.gcs_pubsub_publishing]
}

resource "google_project_iam_member" "event_receiving" {
  project    = data.google_project.project.project_id
  role       = "roles/eventarc.eventReceiver"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.invoking]
}

resource "google_project_iam_member" "artifactregistry_reader" {
  project    = data.google_project.project.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.event_receiving]
}

resource "google_project_iam_member" "dataflow_admin" {
  project    = data.google_project.project.project_id
  role       = "roles/dataflow.admin"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.event_receiving]
}



######################################cloud function config
#create cloud function
resource "google_cloudfunctions2_function" "function" {
  depends_on = [
    google_project_iam_member.event_receiving,
    google_project_iam_member.artifactregistry_reader,
  ]
  name        = "dataflow-trigger"
  location    = var.region
  description = "trigger dataflow job to move cloud storage object from src to dest bucket"

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point # Set the entry point in the code
    environment_variables = {
      BUILD_CONFIG_TEST = "build_test"
    }
    source {
      storage_source {
        bucket = google_storage_bucket.source_bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      PROJECT_ID = data.google_project.project.project_id,
      template_path = "gs://${google_storage_bucket.templates_bucket.name}/${data.google_storage_bucket_object.dataflow_template.name}"
      LOCATION = var.region
      stagging_bucket = "gs://${google_storage_bucket.stagging_bucket.name}"
      temp_bucket = "gs://${google_storage_bucket.temp_bucket.name}"
      dest_path = "gs://${google_storage_bucket.dest_bucket.name}"
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.account.email
  }

  event_trigger {
    trigger_region        = var.region # The trigger must be in the same location as the bucket
    event_type            = var.gcs_event
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.account.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.trigger_bucket.name
    }
  }
}

############################################dataflow config
#allow service account run by cloud function to run dataflow

#assign policy to a service account
data "google_service_account" "worker_sa" {
  account_id = var.worker_sa
}
# data "google_iam_policy" "dataflow_impersonation" {
#   binding {
#     role = "roles/iam.serviceAccountUser"

#     members = [
#       "serviceAccount:${google_service_account.account.email}",
#       "serviceAccount:${var.terraform_service_account}"
#     ]
#   }
# }
#we want cloud function will have roles/iam.serviceAccountUser
resource "google_service_account_iam_binding" "worker_sa_personation" {
  service_account_id = data.google_service_account.worker_sa.name
  role       = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.account.email}"
  ]
}

#############################################config cloud composer

#enable service apis in google with
resource "google_project_service" "composer_api" {
  project = data.google_project.project.project_id
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
}

resource "google_service_account" "composer_sa" {
  account_id   = "composer-sa"
  display_name = "Service Account for Cloud Composer"
}

#assign role to a principle (service account)
resource "google_project_iam_member" "composer_sa_binding" {
  project  = var.project_id
  member   = "serviceAccount:${google_service_account.composer_sa.email}"
  // Role for Public IP environments
  role     = "roles/composer.worker"
}



#note about cloud composer service agent
  #it is google managed service account to manage resource related to cloud composer
#allow clouse composer agent to use compose_sa account
  #allow member to service account to use target service account
resource "google_service_account_iam_member" "compose_agent_sa_binding" {
  service_account_id = google_service_account.composer_sa.id
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-${data.google_project.project.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

# resource "google_composer_environment" "composer_env" {

#   name = "composer-env"
#   region = var.region

#   config {
#     software_config {
#       image_version = "composer-2.0.31-airflow-2.2.5"
#     }

#     node_config {
#       service_account = google_service_account.composer_sa.email
#     }

#   }
# }

########################################config bigquery
#enable on bigquery 
resource "google_project_service" "biqquery_api" {
  project = data.google_project.project.project_id
  service = var.bigquery_api
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
}
#create bigquery table with schema definition
#Dataset IDs must be alphanumeric (plus underscores) and must be at most 1024 characters long.
resource "google_bigquery_dataset" "data_engineer" {
  dataset_id                  = "data_engineer"
  friendly_name               = "data engineer data set"
  description                 = "test dataset for data engineer"
  location                    = var.region
  default_table_expiration_ms = 3600000

  #lables is used for organize resource (filter, cost and used analytics) for each teams or department
  labels = {
    env = "data_engineer"
  }
}

resource "google_bigquery_table" "table_one" {
  dataset_id = google_bigquery_dataset.data_engineer.dataset_id
  table_id   = "table_one"

  labels = {
    env = "data_engineer"
  }

  #reference about string and template: https://developer.hashicorp.com/terraform/language/expressions/strings#strings-and-templates
  #heredoc string allow multiple line string in terraform
  #do not use heredoc string for json or yaml. use jsonencode or yamlencode for json and yaml synstax
  #it is best practice to just load a json file from local
  #file function: read file and return as tring
  schema = file("./table_one_schema.json")

}


#assign role to a principle (service account)
resource "google_project_iam_member" "composer_sa_binding_two" {
  project  = var.project_id
  member   = "serviceAccount:${google_service_account.composer_sa.email}"
  // Role for Public IP environments
  role     = "roles/dataflow.developer"
}

resource "google_service_account_iam_binding" "worker_sa_personation_two" {
  service_account_id = data.google_service_account.worker_sa.name
  role       = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.composer_sa.email}"
  ]
}

# resource "google_bigquery_table" "sheet" {
#   dataset_id = google_bigquery_dataset.default.dataset_id
#   table_id   = "sheet"

#   external_data_configuration {
#     autodetect    = true
#     source_format = "GOOGLE_SHEETS"

#     google_sheets_options {
#       skip_leading_rows = 1
#     }

#     source_uris = [
#       "https://docs.google.com/spreadsheets/d/123456789012345",
#     ]
#   }
# }
#################################config CI CD with cloud build
#enable cloud build api
resource "google_project_service" "cloud_build_service" {
  project = data.google_project.project.project_id
  service = var.cloud_build_api
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
}

#create bucket to storage terraform state
resource "google_storage_bucket" "terraform_state_bucket" {
  name                        = "${var.project_id}-tfstate" # Every bucket name must be globally unique
  location                    = var.region
  storage_class = var.storage_class
  versioning {
    enabled = true
  }


  lifecycle_rule {
    condition {
      age = 0
      num_newer_versions = 2
    }
    action {
      type = "Delete"
    }
  }

}

#grant roles/role.editor for cloudbuild default service account
resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${var.cloudbuild_sa}"
}




