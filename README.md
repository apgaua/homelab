# Homelab projects
In this repo are organized a few projects that I deployed in my proxmox homelab.

## Projects:

### create_proxmox_templates
This project is built using shell script. When you clone it on your Proxmox host, and run create_template.sh with the image parameter, it will download proper cloudimage and set it as a template to be used as clone origin for your virtual machines.

You can also run delete_template.sh with image parameter to proper delete it.

TODO: Finish ansible option.

### deploy_proxmox_instances
This project clone terraform templates that you created manually or using script above.

It read some parameters like, how many instances, control planes and worker nodes if it applies, create proper virtual machines on Proxmox and export their values into a file inside inventory_files folder.

The file will be formated to seamless deploy a kubernetes cluster using kubespray.

### deploy_talos_cluster
This project is full automated to download a Talos Linux iso, put it on Proxmox ISO datastore, create the virtual machines and automatically configure Talos Cluster.

There also some options to install helm Charts using terraform. After running this project, it will export a kubeconfig file ready to be used in the new cluster. 

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->