#specify which cloud provider will provide cloud resource
    #reference about provider and how to authenticate: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
provider "google" {
  project = "toanbui1991-916263"
  region  = "us-west1"
  zone    = "us-west1-a"
}

resource "google_cloud_identity_group" "cloud_identity_group_basic" {
  display_name         = "my-identity-group"
  initial_group_config = "WITH_INITIAL_OWNER"

  parent = "customers/A01b123xz"

  group_key {
      id = "my-identity-group@example.com"
  }

  labels = {
    "cloudidentity.googleapis.com/groups.discussion_forum" = ""
  }
}