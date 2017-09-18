terragrunt = {
  # Include all settings from the root terraform.tfvars file
  include {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = []
  }

  terraform {
    source = "git::ssh://git@github.com/bdbfox/sample-tf-modules.git//data_storage"

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
        "${get_tfvars_dir()}/../../common.tfvars",
        "${get_tfvars_dir()}/../env.tfvars"
      ]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------
redis_node_type           = "cache.t2.small"

# These all come from the network state or other dependent states.
# no value means it will grab from the network state by default
vpc_sg            = ""
public_ssh_sg     = ""
private_subnets   = []
nat_gateway_ips   = []
subnetazs         = []
