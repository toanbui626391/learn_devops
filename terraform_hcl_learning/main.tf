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


#################################config google storage bucket 
#create source bucket, do not use uniform_bucket_level_access to true, use default value (false). So that we hav acl permission control
resource "google_storage_bucket" "toanbui1991" {
  name                        = "dna-poc-training-toanbui1991" # Every bucket name must be globally unique
  location                    = var.region
  storage_class = var.storage_class
  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }

    lifecycle_rule {
    condition {
      age = 0
      num_newer_versions = 7
    }
    action {
      type = "Delete"
    }
  }

}

###################################config data transfer job
data "google_storage_transfer_project_service_account" "default" {
  project = var.project_id
}

# resource "google_storage_bucket" "s3-backup-bucket" {
#   name          = "${var.aws_s3_bucket}-backup"
#   storage_class = "NEARLINE"
#   project       = var.project
#   location      = "US"
# }

resource "google_storage_bucket_iam_member" "bucket_role_binding" {
  bucket     = google_storage_bucket.toanbui1991.name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${data.google_storage_transfer_project_service_account.default.email}"
  depends_on = [google_storage_bucket.toanbui1991]
}

# resource "google_pubsub_topic" "topic" {
#   name = "${var.pubsub_topic_name}"
# }

# resource "google_pubsub_topic_iam_member" "notification_config" {
#   topic = google_pubsub_topic.topic.id
#   role = "roles/pubsub.publisher"
#   member = "serviceAccount:${data.google_storage_transfer_project_service_account.default.email}"
# }
#prepare data for data transfer

# data "google_storage_bucket" "src_bucket" {
#   name = var.src_bucket_name
# }

resource "google_storage_transfer_job" "bucket_to_bucket" {
  description = "move data from one bucket to another bucket on gs daily. Author: toanbui1991"
  project     = var.project_id

  transfer_spec {
    # object_conditions {
    #   max_time_elapsed_since_last_modification = "600s"
    #   include_prefixes = [
    #     ".",
    #   ]
    # }
    # transfer_options {
    #   delete_objects_unique_in_sink = false
    # }
    gcs_data_source {
      bucket_name = var.src_bucket_name
    #   path = "/"
    }
    gcs_data_sink {
      bucket_name = var.dest_bucket_name
    }
  }

  schedule {
    schedule_start_date {
      year  = 2022
      month = 11
      day   = 23
    }
    schedule_end_date {
      year  = 2022
      month = 12
      day   = 10
    }
    start_time_of_day {
      hours   = 23
      minutes = 30
      seconds = 0
      nanos   = 0
    }
    repeat_interval = "604800s"
  }

}



