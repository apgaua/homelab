# Deploy proxmox instances using terraform

### Before everything
    1 - You should have a running proxmox server.

    2 - Create user and roles to allow terraform access proxmox server.
        Follow documentation on [Telmate Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs) doc

    3 - Create SSH keys to allow node access without password.
        To create the keys, just follow the instructions on [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server#step-1-creating-ssh-keys) documentation.

### Terraform init
First of all, rename the files located in the environment folder and set variable values for your project.

In this case, I host state and statelock in a s3 bucket and then init using backend variablis as bellow:
`terraform init -backend-config=environment/backend.tfvars`

If you do not want to use state file on s3, you can just run: 
`terraform init`

### Terraform apply

`terraform apply -var-file=environment/variables.tfvars`