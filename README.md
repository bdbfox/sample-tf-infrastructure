# Sample terraform infrastructure

## About

This repo has the configuration for the networking, cluster, and codebuild setup to be able to build the vpc, security groups, repositories etc to enable an entire environment. You can have as many environments as you like, but currently they are separated out by non-prod and prod accounts. Within each account there is only one vpc which is setup in the `common` folder. The `common` folder houses infrastructure elements that are not unique per environment, such as vpc, ecr, codebuild, etc...


## Repo structure

The repos are structured like so:
- #### sample-tf-infrastructure

  That would be _this_ repo. This is where you should start. The instructions below cover the whole sample of doing everything. This repo defines all of the networking and shared components like ECS clusters, databases, etc... per environment. This can also include definitions across multiple accounts (like non-prod v. prod) or across multiple regions.

- #### sample-tf-modules

  https://github.com/bdbfox/sample-tf-modules

  This repo has all of the various terraform modules which get reused by the infrastructure repo above. There shouldn't be any changes needed to that unless you want change the actual infrastructure.

- #### hello-service

  https://github.com/bdbfox/hello-service

  A sample node service that just returns a hello message.

- #### world-service

  https://github.com/bdbfox/world-service

  A sample node service that does nothing but spit out the environment variable for redis. It doesn't actually connect to redis - that would be too obvious.

## Folder structure

For this repository the folders are setup like so:

```
root
├── <account>             # ie. non-prod, prod
│   ├── <region>          # ie. us-east-1, us-west-2
│   │   ├── common        # all global elements for a region go here
│   │   │   └── <module>  # the module that needs to be installed, ie. database
│   │   ├── <env>         # each environment has it's own folder
│   │   │   │── <module>  # the module that needs to be installed, ie. database
│   │   │   └── <module>  # another module
│   │   └── <env>         # more environments as needed
│   │       │── <module>  # the module that needs to be installed, ie. database
│   │       │── <module>  # another module
│   │       └── ...       # more modules that only this environment has
│   │
│   └── <region>          # another region
│      ├── common         # all global elements for this region go here
│      └── ...            # etc...
│
├── <account>             # ie. non-prod, prod
...
```

## Getting started

1. To get started you need to install terraform and terragrunt. There's a setup.sh script which will take care of this for you. So if you want just run the following command:

  ```sh
  ./setup.sh
  ```

  You can find more information here on specifics about terragrunt:
  `https://github.com/gruntwork-io/terragrunt`

  > **NOTE: This script assumes you are running this on a mac.**

2. Setup your aws profile to have the proper credentials. The default setup of this is to use a profile called `dcgapi-dev`. This profile is for the `fbcd-sandbox` account. To continue to use that profile configure your `~/.aws/credentials` file to append the following:

  ```
  [dcgapi-dev]
  aws_access_key_id = <PUT ACCESS KEY HERE>
  aws_secret_access_key = <PUT SECRET KEY HERE>
  ```

  If you want to use a different profile, just go into the `non-prod/us-east-2` folder and adjust the `common.tfvars` file to have the account id and profile that you want to use.

  > **NOTE: Ensure that you haven't exported any AWS credentials into you bash shell. Otherwise those will take precedence.**

3. If this is the first time you are running this, you'll want to setup the common folder first (ie. vpc, etc..) as the other environments need that to work.

  If you want to setup these items in a different region, then copy the region folder to a new folder (named for your region) and change the region parameter in the `non-prod/<new_region_name>/common.tfvars` file.

  When you are ready run the following commands:

  ```sh
  cd non-prod/us-east-2/common
  # first check your work
  terragrunt plan_all
  # if you like the result
  terragrunt apply_all
  ```

  If you want to run terragrunt against your local files (not the git repo), then you will have to run the commands in each folder as you can't use that method with the plan-all. Instead, do the following:

  ```sh
  cd non-prod/us-east-2/common/network
  # first check your work
  terragrunt plan --terragrunt-source ../../../../../sample-tf-modules//network
  # if you like the result
  terragrunt apply --terragrunt-source ../../../../../sample-tf-modules//network
  ```

  > **NOTE: The common.tfvars assumes you are using a specific keypair. If you don't have that keypair, then change the value to one that you do have.**

4. Next, let's setup the database, consul, ECS cluster, and load balancer. We assume that there is one of those per environment. There's no reason there could be more (or one per VPC), but that's how this is configured for now. For this example, we'll setup the `dev` environment.

  ```sh
  cd non-prod/us-east-2/dev
  # first check your work
  terragrunt plan_all
  # if you like the result
  terragrunt apply_all
  ```

  Again, if you want to use local files instead of the git repo, you can follow the example above for each folder. There are dependencies between the modules if you go this route though, so run them in the following order:

  ```sh
  cd non-prod/us-east-2/dev/consul
  terragrunt plan --terragrunt-source ../../../../../sample-tf-modules//consul
  cd ../data_storage
  terragrunt plan --terragrunt-source ../../../../../sample-tf-modules//data_storage
  cd ../service_cluster
  terragrunt plan --terragrunt-source ../../../../../sample-tf-modules//service_cluster
  ```

  If you want to use a different environment or add a new one, then copy all of the dev files to a new environment folder, and change the `<env_name>/env.tfvars` and `<env_name>/terraform.tfvars` value accordingly.

5. Now we can run terragrunt from the actual service. Let's go to the hello-service and prepare it to be built.

  **TODO: show how to build service**

  For now, I'm not detailing how to build a docker image and how to push it into ECR (or docker hub) nor did I actually do that, so these services won't actually run since they have no real images. However, I suspect you already know how to do that. The important part is that you can choose the image in your task definition. These are defined in the service repos themselves in each of the folders that match up with the service. They are defined per region currently, but there's no reason they couldn't be defined at each version level.

  ```yaml
  # in <service>/tf/<account>/<region>/common.tfvars
  docker_image = "776609208984.dkr.ecr.us-east-2.amazonaws.com/hello-service"
  ```

  The docker tag is defined inside the deploy file at each version. Of course, you can override the docker_image here too if you needed to.

  ```yaml
  # in  <service>/tf/<account>/<region>/<env>/<tag>/<version>/deploy.tfvars
  docker_tag = "v1.2.3"
  # docker_image = "776609208984.dkr.ecr.us-east-2.amazonaws.com/hello-service-v1a"
  ```

  This will obviously result in a task definition that looks like:

  ```js
  {
    ...
    "image": "776609208984.dkr.ecr.us-east-2.amazonaws.com/hello-service:v1.2.3",
    ...
  }
  ```

6. So...let's actually deploy the hello service. There are a couple options here. Starting from the root folder of the hello-service repo, if you want to deploy all of the dev services for hello you can simply start by going into the dev folder. Then, run `terragrunt plan-all` to first see the results and `terragrunt apply-all` to make it so. Similarly, you can do that from any folder to deploy as many or as few services as you want. Some examples:

  ```sh
  # from hello-service repo
  # to deploy EVERYTHING (all versions) in the us-east-2 region
  cd tf/non-prod/us-east-2
  terragrunt plan-all

  # to deploy all of the dev services (v1 blue, v1 green, and v2 blue)
  cd tf/non-prod/us-east-2/dev
  terragrunt plan-all

  # to deploy just v1 services (v1 blue and v1 green)
  cd tf/non-prod/us-east-2/dev/v1
  terragrunt plan-all

  # and finally, to deploy just blue v1 in dev (only v1 blue)
  cd tf/non-prod/us-east-2/dev/v1/blue
  terragrunt plan
  ```

7. The world service works exactly the same way, except that it uses a redis cluster as well. Note that this is never defined in any environment variables. This is retrieved directly from the environment state file. The only differences here are the deploy settings, and the common variables to make them match the service name.

8. Last but not least you can destroy elements the same way, by reversing the steps above and using `terragrunt destroy-all` from the appropriate folders.
