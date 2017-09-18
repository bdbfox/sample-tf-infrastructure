terragrunt = {
  remote_state {
    backend = "s3"
    config {
      bucket          = "sample-tf-non-prod-state-us-east-2-776609208984"
      encrypt         = true
      key             = "common/${path_relative_to_include()}/terraform.tfstate"
      lock_table      = "sample-tf-non-prod-lock-table"
      profile         = "dcgapi-dev"
      region          = "us-east-2"
    }
  }
}
