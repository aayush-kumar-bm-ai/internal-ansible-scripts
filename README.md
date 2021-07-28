# bright-ansible-scripts
This repo contains ansible scripts to create infrastructure

## Installing ansible
- Installing it on Ubuntu
```
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo add-apt-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
```
- Installing it on Mac OS
``` brew install ansible```

More installation details: [Installing Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Setting up environment to run ansible scripts
- Clone the repository - ```https://github.com/BrightMoney-AI/bright-ansible-scripts.git```
- Navigate inside ```bright-ansible-scripts``` directory and you will find the subdirectories with respective service name
- Navigate inside the desired service directory and it contains the production, dev and staging environment folders
- Go to the desired environment folder
- And run ```ansible-playbook main.yml -i hosts```

## Roles
Ansible role is a set of tasks to configure a host to serve a certain purpose like configuring a service. Roles are defined using YAML files with a predefined directory structure
A role directory structure contains directories: defaults, vars, tasks, files, templates, meta, handlers. Each directory must contain a main.yml file which contains relevant content. Let’s look little closer to each directory.
  ** defaults: ** contains default variables for the role. Variables in default have the lowest priority so they are easy to override.
  ** vars: ** contains variables for the role. Variables in vars have higher priority than variables in defaults directory.
  ** tasks: ** contains the main list of steps to be executed by the role.
  ** files: ** contains files which we want to be copied to the remote host. We don’t need to specify a path of resources stored in this directory.
  ** templates: ** contains file template which supports modifications from the role. We use the Jinja2 templating language for creating templates.
  ** meta: ** contains metadata of role like an author, support platforms, dependencies.
  ** handlers: ** contains handlers which can be invoked by “notify” directives and are associated with service.
  
  
In our code we have created ansible roles under ** roles ** directory. The ** roles ** directory has following roles:
  ** ec2 ** : It helps us to create ec2 instance in AWS with or without additional based on the input specified in ```ec2_vars.yml```
  ** ec2_setup ** : Helps in mounting volume if additional volume is needed and to make sure pip.conf and ec2_connect are added.
  ** filebeat ** : Helps in configuring filebeat and also it will install filebeat if not installed earlier
  ** node_exporter ** : Helps in installing and setting up node exporter service on ec2 instance
  ** statsd_exporter ** : Helps in installing and setting up statsd exporter service on ec2 instance

## How to add new service and create an ec2 instances
In order to create an instance:
1. Create a directory inside with name of the service
2. Create production, dev and stage subdirectories inside the directory created in (1)
3. Copy ``` ec2_vars.yml, hosts, main.yml and filebeat_vars.yml``` from any existing service directory
4. Fill the details in ```ec2_vars.yml``` as below
```
---
instances:
 - INSTANCE_NAME_1
 - INSTANCE_NAME_2

instance_group_name: INSTANCE_GROUP_NAME
instance_key_name: backend-16-08-19
ami_id: ami-0d6338e316cc0dce2
instance_type: t3.medium
instance_region: us-west-2
vpc_subnet_id: subnet-03e86548fbbfcbf2a
security_group_ids: ["sg-0d2c34bb1cc93d18e"]
root_volume_type: gp2
root_volume_size: 30
number_of_instances: 1
is_public_ip_needed: false
additional_volume_needed: false
is_mounting_volume_needed: false
additional_volume_size: 128
additional_volume_type: gp2
additional_volume_device_name: /dev/sdd
nginx_needed: true
python_version: 3.8
```
Change INSTANCE_NAME in instances array and INSTANCE_GROUP_NAME 

4. Replace hosts value at the second occurrence wth INSTANCE_GROUP_NAME in main.yml

5. Change app name in APP_NAME and ENVIRONMENT ```filebeat_vars.yml```
```
filebeat_download_url: https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.12.0-amd64.deb
filebeat_download_path: /tmp/filebeat.deb
app_name: APP_NAME
env: ENVIRONMENT
celery_logs_path: /app/logs/celery/celerystdout.log
celery_beat_logs_path: /app/logs/celery_beat/celerystdout.log
gunicorn_logs_path: /app/logs/gunicorn/gunicornstdout.log
nginx_access_logs_path: /app/logs/nginx/access.log
nginx_error_logs_path: /var/log/nginx/error.log
ossec_logs_path: /app/ossec/logs/alerts/alerts.log
```
6. That's it run ```ansible-playbook main.yml -i hosts``` it will create the instances with name specified in ** instances array in ```ec2_vars.yml``` **




