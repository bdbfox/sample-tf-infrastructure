terragrunt = {
  # Include all settings from the root terraform.tfvars file
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "git::ssh://git@github.com/bdbfox/sample-tf-modules//network"

    extra_arguments "custom_vars" {
      commands = [
        "apply",
        "destroy",
        "init",
        "plan",
        "import",
        "push",
        "refresh"
      ]

      required_var_files = [
        "${get_tfvars_dir()}/../../common.tfvars"
      ]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------
vpc_cidr             = "10.20.0.0/16"
subnetaz1            = "us-east-2a"
subnetaz2            = "us-east-2b"
subnetaz3            = "us-east-2c"
private_subnet_cidr1 = "10.20.1.0/24"
private_subnet_cidr2 = "10.20.2.0/24"
private_subnet_cidr3 = "10.20.3.0/24"
public_subnet_cidr1  = "10.20.11.0/24"
public_subnet_cidr2  = "10.20.12.0/24"
public_subnet_cidr3  = "10.20.13.0/24"
