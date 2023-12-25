# hw-hl

# HW-HL

Homework

Objective:

terraform and ansible role for deploying web application servers under high load and fault tolerance
the work should include:
 - nginx 
 - uwsgi/unicorn/php-fpm
 - unclustered mysql/mongodb/postgres/redis database
 - gfs2
 - fault tolerance of backend and nginx servers
 - session fault tolerance
 - faiover without loss of static content
 - ansible scripts with tuning of sysctl parameters
 - nginx settings
 - connection pooling
 - README file


## There are manifests in repo:


 - yandex.cloud balancer, which will periodically health-check nginx wokers and balance incoming traffic between them.
 - 2 nginx wokers, which in turn are configured for simple balancing of traffic to web application backends
 - 2 backend workers, on which a simple application on go is running in systemd, listening on port 8090. When a request is made, it gives the name of the backend (to understand which backend the request from Nginx came to) and the database version.
 - 1 iscsi target distributing disk to backends
 - 1 Postgresql 13 database instance with a test database and a test database user to receive requests from the backend
 - 1 virtual machine with ansible installed to deploy the above-mentioned roles. It also acts as Jump host of the project, as the only one has an external ip (not counting yandex.cloud balancer, it also has an external ip).





## Pre-requirements

To run this project, you will need to prepare your yandex cloud, 


and then set environment variables:
```
export TF_VAR_yc_token=$(yc iam create-token)
export TF_VAR_cloud_id=$(yc config get cloud-id)
export TF_VAR_folder_id=$(yc config get folder-id)
```
in this case the terraform.tfvars file is not needed






## Deployment

To deploy this project run

```bash
  git clone https://github.com/abelovn/hw-hl.git && cd  hw-hl && terraform init && terraform plan && terraform apply  -auto-approve 
  
```


To check the stand operation it is necessary to go to the balancer's ip address yandex.cloud in a browser or using curl.

```
curl http://{external_ip_address_lb}
```


To see the response from the database at url http://{external_ip_address_lb}/db




To see the image output from iSCSI-connected GFS2 at url http://{external_ip_address_lb}/image.



It is possible to ssh to a jump-host, from which you can get to any VM inside the stand. To do this from the working folder of the project you need to execute:


```
$ ssh almalinux@{external_ip_address_ansible} -i id_rsa
```

external_ip_address_ansible look in terraform output or yandex.cloud console.



From the jump-host you can ssh to all machines inside the project by their internal ip addresses or hostname (nginx0, nginx1, backend0, backend1, db, iscsi).

If we stop one nginx service at a time on nginx0, nginx1 balancers, we can see that requests still go to backends due to yandex.cloud balancer.

If you stop backend0, backend1 one by one, you can see that requests will go only to the running backend due to the balancer in nginx. Static processing (image output) will also continue to work. If you start the disabled backend again - both backends will be up and running after some time.

Nginx "tuning". The following tuning is done on nginx servers to improve performance:

Operating system settings:

 - increasing ulimits hard and soft for nginx to 65536
 - increase sysctl fs.file-max to 324567

nginx settings:

 - sendfile on;
 - tcp_nopush on;
 - types_hash_max_size 2048;
 - gzip on;
 - gzip_disable "msie6";
 - gzip_proxied any;
 - gzip_comp_level 3;
 - gzip_buffers 16 8k;
 - gzip_http_version 1.1;
 - gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript image/svg+xml;
 
 
 
Sample of output:


Outputs:

```

external_ip_address_ansible = [
  "158.160.39.59",
]
external_ip_address_lb = tolist([
  {
    "external_address_spec" = toset([
      {
        "address" = "158.160.132.74"
        "ip_version" = "ipv4"
      },
    ])
    "internal_address_spec" = toset([])
    "name" = "listener01"
    "port" = 80
    "protocol" = "tcp"
    "target_port" = 80
  },
])
internal_ip_address_backend = [
  "192.168.100.4",
  "192.168.100.29",
]
internal_ip_address_db = [
  "192.168.100.20",
]
internal_ip_address_iscsi = [
  "192.168.100.5",
]
internal_ip_address_nginx = [
  "192.168.100.7",
  "192.168.100.30",
] 

```
