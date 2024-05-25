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


## Ansible learnings

### Commands

- `ansible-inventory -i inventory/servers.ini --list`
- `ansible web_servers  -m ping -i inventory/servers.ini`


### Resources

- https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html