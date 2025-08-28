# homelab
Repository used to organize my homelab projects

## Description
In this repo there's 2 projects that I use to automate Virtual Machine and Template deployments on Proxmox.

#### create_proxmox_templates
Here are the files (mostly bash scripts) that download a cloudimage and set it as a template on Proxmox.
You can run it on proxmox server terminal, or using ansible with command:
`ansible-playbook -i inventory.ini proxmox_template.yml -u <proxmox_user> --ask-pass -e "env_file=images/<templateyouwanttodeploy>.env"`

#### deploy_proxmox_templates