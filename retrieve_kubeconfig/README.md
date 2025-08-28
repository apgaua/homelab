# Retrieve kubeconfig from baremetal cluster.

## Command

ansible-playbook -i iinventory.ini fetch_kubeconfig.yml -b -v --private-key=~/.ssh/id_rsa -k

## Pre-requisites

Kubernetes and Python interpreter must be installed on server.
