# Instructions to Test this action <!-- omit in toc -->

Do all tests in `devops` account

- [1. Instance Creation](#1-instance-creation)
- [2. Running Tests](#2-running-tests)

## 1. Instance Creation

Create an ec2 instance using [lazy-terraform](https://github.com/variant-inc/lazy-terraform/tree/master/ec2)

Things to note while creating it:

1. Add security group rules to your current IP or open-vpn security group. If you use security group, you should be connected to `openvpn` when testing the action. Use `vpn.ops-drivevariant.com` (devops) connection

    Example:

    ```bash
    security_group_rules_data = {
      "eks-ssh": {
        "type" :"ingress",
        "from_port":"22",
        "to_port":"22",
        "protocol":"TCP",
        "description":"variant-stage eks",
        "source_security_group_id": "sg-07c9e3793bdf97612",
        "cidr_blocks": null
      }
    }
    ```

## 2. Running Tests

1. Copy `values.yaml` from [tests/repo/.octopus/values.yaml](repo/.octopus/values.yaml) and add to [group_vars/](../group_vars/). Make any modifications that you need
2. Get new sso credentials for ops profile. If you do not have ops profile do

  `aws configure sso` and select Variant-ops and give profile name as ops

  `aws sso login --profile ops`
3. Modify [aws_ec2.yml](../aws_ec2.yml) and update the `filters:instance-id` with `instance-id` that you got from step 1.
4. Add a file `all` in [group_vars/](../group_vars/) folder. Contents of the file is

  ```yaml
  git:
  url: ## commit url
  commit_sha: ## commit sha
  secret_token: ## Personal Access Token
  username: ## Name of the github User

  instance_user: ubuntu
  ```

5. Run [tests/deploy.ps1](deploy.ps1)
