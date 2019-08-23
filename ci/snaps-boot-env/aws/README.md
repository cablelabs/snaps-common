# snaps-boot CI environment build
Readme for information for creating a _snaps-boot_ CI

## Build Host Requirements
- Ansible has been installed onto the terraform host
- Download and install Terraform from <https://www.terraform.io/downloads.html>
- Download https://github.com/cablelabs/snaps-config
- Download https://github.com/cablelabs/snaps-common

## Setup bare metal host on AWS and execute deployment from the build host
Run the following bash command from this directory:
```bash
export TF_CLI_CONFIG_FILE="{snaps-config dir}/aws/terraform_rc"
terraform init
terraform apply -auto-approve \
-var-file='{snaps-config dir}/aws/snaps-ci.tfvars' \
-var-file='{snaps-common dir}/ci/snaps-boot-env/boot-env.tfvars' \
-var build_id={some unique readable value}
```

## Cleanup
Always perform cleanup after completion by running the following command from this directory:
```bash
terraform destroy -auto-approve \
-var-file='{snaps-config dir}/aws/snaps-ci.tfvars' \
-var-file='{snaps-common dir}/ci/snaps-boot-env/boot-env.tfvars' \
-var build_id={some unique readable value}
```
