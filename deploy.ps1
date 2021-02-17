Write-Information "Creating SSH Key"
"y" | ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -P """"

Rename-Item -Path group_vars/all.yaml -NewName all

ce ansible-galaxy collection install ansible.posix
ce ansible-galaxy collection install amazon.aws

ce pip3 install -U boto3 botocore boto

ce ansible-playbook ./site.yml -i ./aws_ec2.yml -v
