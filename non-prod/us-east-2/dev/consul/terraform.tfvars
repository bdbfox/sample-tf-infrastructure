terragrunt = {
  # Include all settings from the root terraform.tfvars file
  include {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = []
  }

  terraform {
    source = "git::ssh://git@github.com/bdbfox/sample-tf-modules.git//consul"

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
ami_ecs_optimised = "ami-62745007"
instance_type     = "t2.small"
max_size          = "3"
min_size          = "3"

# These all come from the network state or other dependent states.
# no value means it will grab from the network state by default
vpc_sg            = ""
public_web_sg     = ""
public_ssh_sg     = ""
public_subnets    = []
private_subnets   = []
