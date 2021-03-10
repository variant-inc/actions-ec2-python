Write-Information "Creating SSH Key"
"y" | ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -P """"

ansible-galaxy collection install ansible.posix
ansible-galaxy collection install amazon.aws
ansible-galaxy collection install community.kubernetes

pip3 install -U boto3 botocore boto openshift pyyaml kubernetes --no-warn-script-location

aws eks update-kubeconfig --name variant-ops --region us-west-2 --profile ops

ansible-playbook ../site.yml -i ../aws_ec2.yml -v

kubectl apply -f /tmp/service-monitor.yaml
Remove-Item -Path /tmp/service-monitor.yaml
