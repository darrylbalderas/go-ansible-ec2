# go-ansible-ec2

Repo for playing around with ansible and golang cli

## Pre-req
- Terraform
- Ansible
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install ansible
    ```
- Inventory folder `mkdir -p inventory`

## Deploy infra

```bash
terraform plan
terraform apply
terraform output
```

## Check SSH connection

`make login`

## Execute ansible playbook for ec2_setup

`make setup`

## Execute remote command

`make remote-test`
