
#project config
variable "project_id" {
  type    = string
  default = "airflow-gke-338120-352104"
}

variable "region" {
  type    = string
  default = "asia-southeast1"
}

variable "zone" {
  type    = string
  default = "asia-southeast1-b"
}

variable "terraform_service_account" {
  type    = string
  default = "terraform-personal@airflow-gke-338120-352104.iam.gserviceaccount.com"
}

#storage config
variable "bucket_location" {
  type    = string
  default = "asia-southeast1"
}


#function config
variable "runtime" {
  type    = string
  default = "python38"
}

variable "python_source" {
  type    = string
  default = "./python-docs-samples/functions/v2/storage/function-source.zip"

}
#function to run in the source code
variable "entry_point" {
  type    = string
  default = "hello_gcs"
}

variable "gcs_event" {
  type    = string
  default = "google.cloud.storage.object.v1.finalized"
}


