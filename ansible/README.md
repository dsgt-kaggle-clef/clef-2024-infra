# ansible

This directory contains ansible for configuring GCP resources.
In particular, we provision a centralized scheduler for luigi so that we can parallelize tasks across multiple VMs.

## installing ansible

```bash
pip3 install ansible google-auth

# also make application default credentials are available
gcloud auth application-default login
```

## configuring luigi and label-studio

```bash
ansible-inventory -i inventory.services.gcp.yml --graph
ansible all -i inventory.services.gcp.yml -m ping
ansible-playbook -i inventory.services.gcp.yml services.yml
```

## configuring a dev VM

The instance must be tagged with `app: dev`.
Running this ansible role will update all machines with `gh`, `sops`, and `tfenv`.

```bash
ansible-inventory -i inventory.dev.gcp.yml --graph
ansible all -i inventory.dev.gcp.yml -m ping
ansible-playbook -i inventory.dev.gcp.yml dev.yml
```

We can run a faster subset of commands that can be run regularly:

```bash
ansible-playbook -i inventory.dev.gcp.yml dev.yml --skip-tags=slow
# we can also run for a single host
ansible-playbook -i inventory.dev.gcp.yml dev.yml --skip-tags=slow --limit=birdclef-dev
```

We also have a shared instance which has a bigger nvme disk for processing large datasets.

```bash
ansible-playbook -i inventory.big-disk-dev.gcp.yml big-disk-dev.yml
```

## links

- https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html#content-organization
- https://docs.ansible.com/ansible/latest/collections/google/cloud/gcp_compute_inventory.html
- http://matthieure.me/2018/12/31/ansible_inventory_plugin.html
- https://www.bionconsulting.com/blog/gcp-iap-tunnelling-on-ansible-with-dynamic-inventory
- https://charlesreid1.com/wiki/Ansible/Nginx_Playbook
- https://gist.github.com/mattiaslundberg/ba214a35060d3c8603e9b1ec8627d349
- https://blog.gmaliar.com/generating-lets-encrypt-certificates-for-nginx-using-ansible-9fd27b90993a
