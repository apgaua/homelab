# Deploy proxmox instances using terraform


## Terraform init
First of all, rename the files located in the environment folder and set variable values for your project.

In this case, I host state and statelock in a s3 bucket and then init using backend variablis as bellow:
terraform init -backend-config=environment/backend.tfvars

If you do not want to use state file on s3, you can just run: 
terraform init

## Terraform apply

terraform apply -var-file=environment/MYCUSTOMFILE.tfvars