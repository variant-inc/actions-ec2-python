# Lazy Ansible EC2 Action

Ansible Playbook for deploying applications to ec2

This playbook currently supports only `python` deployment. Others can be deployed using `single_runs`

## Instructions

### How to add to your repository

Copy the example [build-octo-push.yaml](examples\.github\workflows\build-octo-push.yaml) to `.github/workflows` folder. This might need to be modified as per your requirements.

Make sure to add the required `secrets` to your github repository mainly the following

- OCTOPUS_PROJECT_NAME
- OCTOPUS_SPACE_NAME
- MASTER_BRANCH

### Add customized values.yaml

values.yaml is your bread and butter for customizing your deployment.

There are 4 major types of runs supported

1. [Single Runs](#Single-Runs)
2. [Cron Jobs](#Cron-Jobs)
3. [Systemd Services](#Systemd-Services)
4. [Backup Services](#Backup-Services)
5. [Misc Vars](#Misc-Vars)

#### Single Runs

These are run when the application is deployed the very first time.

| parameter  | description                                                                                                                            | example    | default |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------- |
| name       | Name of the script. There should not be any spaces                                                                                     | HelloWorld |         |
| entrypoint | Command that should be run. Can be multi line and it supports jinja template                                                           | `./run.sh` |         |
| background | `(optional)` Should the run happen in background? Running in background will allow octopus to move on to the next stage in environment | yes        | no      |

#### Cron Jobs

These are run when the application is deployed the very first time.

| parameter  | description                                                                                                                   | example        |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------- | -------------- |
| name       | Name of the script. There should not be any spaces                                                                            | HelloWorld     |
| entrypoint | Command that should be run. Can be multi line and it supports jinja template                                                  | `./run.sh`     |
| cron       | Cron Time                                                                                                                     | `"25 * * * *"` |
| disabled   | `(optional)` Deploy cron but disable it. Refer here for acceptable values <https://yaml.org/type/bool.html>. Default is `yes` | no             |

#### Systemd Services

These are run as a service

| parameter  | description                                                                  | example    |
| ---------- | ---------------------------------------------------------------------------- | ---------- |
| name       | Name of the script. There should not be any spaces                           | HelloWorld |
| entrypoint | Command that should be run. Can be multi line and it supports jinja template | `./run.sh` |

### Backups

These allow you to take backups of certain folders to S3 bucket

| parameter     | description                               | example     |
| ------------- | ----------------------------------------- | ----------- |
| name          | A friendly name. No spaces                | HelloWorld  |
| bucket_name   | S3 bucket name                            | hello-world |
| bucket_folder | Folder in the S3 bucket                   | dir         |
| dir           | Location to local dir relative to app dir | data        |

### Misc Vars

| parameter       | description                           | example    | default     |
| --------------- | ------------------------------------- | ---------- | ----------- |
| clone_dir       | `(optional)` Name of the clone dir    | HelloWorld | `repo name` |
| instance_user   | `(optional)` user name in the machine | ro         | `ubuntu`    |
| python.manager  | conda/pip                             | conda      | pip         |
| python.env_name | Env name for virtual-env or conda     | usxopt     | env         |

## Example

```yaml
clone_dir: usxopt

instance_user: ubuntu

python:
  manager: conda
  env_name: usxopt

single_runs:
  - name: CreateDirIfNotExists
    entrypoint: mkdir -p ../data
  - name: Optimizer
    entrypoint: ./run.sh >> usxopt.log 2>&1
    background: true

cron_entries:
  - name: RejectedLoads
    entrypoint: |
      cd ../
      python usxopt/appendRejectedLoads.py >> usxopt/appendRejectedLoads.log 2>&1
    cron: "*/5 * * * *"
    disabled: no
  - name: Optimizer
    entrypoint: run.sh >> usxopt.log 2>&1
    cron: "0 * * * *"
    disabled: no

backups:
  - name: data
    bucket_name: usxopt
    bucket_folder: "data"
    # dir relative to home dir. For example: if dir is hello, the absolute dir is /home/ubuntu/hello
    dir: "../data"
```

More examples can be found at [examples](examples) folder
