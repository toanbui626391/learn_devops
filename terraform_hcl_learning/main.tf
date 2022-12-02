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
  location                    = var.location
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
#################################config bigquery dataset and table
#create bigquery table with schema definition
#Dataset IDs must be alphanumeric (plus underscores) and must be at most 1024 characters long.
#bigquery have three basic resource or object
  #dataset: collect of table
  #table: table
  #job: action that bigquery run on behalf of user to load data, export data, query or copy data
  #routine: user define function or stored procedure belong to dataset
#to avoid fixed thought (try to solve proble with wrong tools):
  #look for docs and search for resource type needed (bigquery)
  #quicly review all the action options to find appropriate tools
resource "google_bigquery_dataset" "ds_toanbui1991" {
  dataset_id                  = "ds_toanbui1991"
  friendly_name               = "dataset of toanbui1991"
  description                 = "dataset of toanbui1991"
  location                    = var.location
  # default_table_expiration_ms = 864000000

  #lables is used for organize resource (filter, cost and used analytics) for each teams or department
  labels = {
    env = "data_engineer"
  }
}

#this resource only define table, loading data will use job resource
resource "google_bigquery_table" "tb_sales" {
  dataset_id = google_bigquery_dataset.ds_toanbui1991.dataset_id
  table_id   = "sales_toanbui1991"
  # expiration_time = 864000000
  time_partitioning {
    type = "DAY"
    expiration_ms = 864000000
  }

  labels = {
    env = "data_engineer"
  }

  schema = file("./tb_sales_schema.json")

  depends_on = [
    google_bigquery_dataset.ds_toanbui1991
  ]

}

#load data into table
resource "google_bigquery_job" "csv_to_bq" {
  job_id     = "csv_to_bq"
  #job can not find dataset error:
    #job can not fine dataset because they in different location (region)
  project = var.project_id
  location = var.location

  labels = {
    "my_job" ="csv_to_bq"
  }

  load {
    source_uris = [
      "gs://dna-poc-training-saurav/store_sales.csv",
    ]

    destination_table {
      # project_id = google_bigquery_table.tb_sales.project
      # dataset_id = google_bigquery_dataset.ds_toanbui1991.id
      # table_id   = "projects/${google_bigquery_table.tb_sales.project}/datasets/${google_bigquery_table.tb_sales.dataset_id}/tables/${google_bigquery_table.tb_sales.table_id}"
      table_id = google_bigquery_table.tb_sales.id
    }
    #config expiration time at load
    time_partitioning {
      type = "DAY"
      expiration_ms = 864000000
    }

    skip_leading_rows = 1
    # schema_update_options = ["ALLOW_FIELD_RELAXATION", "ALLOW_FIELD_ADDITION"]

    write_disposition = "WRITE_TRUNCATE"
    # autodetect = true
  }
  depends_on = [
    google_bigquery_dataset.ds_toanbui1991,
    google_bigquery_table.tb_sales
  ]
}

###############################################create scheduled query

#create service account
resource "google_service_account" "bq_sq" {
  account_id   = "bigquery-sa"
  display_name = "bq_sa"
}
#binding sa to role
resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.bq_sq.email}"
}
resource "google_bigquery_table" "salesagg_toanbui1991" {
  dataset_id = google_bigquery_dataset.ds_toanbui1991.dataset_id
  table_id   = "salesagg_toanbui1991"
  # expiration_time = 864000000
  time_partitioning {
    type = "DAY"
    expiration_ms = 864000000
  }

  labels = {
    env = "data_engineer"
  }

  schema = file("./tb_salesagg_toanbui1991.json")

  depends_on = [
    google_bigquery_dataset.ds_toanbui1991
  ]

}

# resource "google_bigquery_data_transfer_config" "schedule_query" {

#   display_name           = "schedule_query"
#   location               = var.location
#   data_source_id         = "schedule_query_data_source_id"
#   schedule               = "every day 01:00"
#   destination_dataset_id = google_bigquery_dataset.ds_toanbui1991.id
#   params = {
#     destination_table_name_template = "my_table"
#     write_disposition               = "WRITE_TRUNCATE"
#     query                           = file("./sale_agg.sql")
#   }
# }



