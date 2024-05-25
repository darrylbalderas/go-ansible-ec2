EC2_PEM_KEY := $$(terraform output -raw ec2_pem_key)
EC2_PUBLIC_IP := $$(terraform output -raw ec2_public_ip)

login:
	ssh -i "~/.ssh/$(EC2_PEM_KEY)-use1.pem" ec2-user@$(EC2_PUBLIC_IP)

setup:
	ansible-playbook -i inventory/servers.ini playbooks/ec2_setup.yml

remote-test:
	ssh -i "~/.ssh/$(EC2_PEM_KEY)-use1.pem" ec2-user@$(EC2_PUBLIC_IP) ./main