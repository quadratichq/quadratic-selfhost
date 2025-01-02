# Quadratic Self-Hosting

Implement the entire Quadratic stack outside of Quadratic. The use cases we currently support:

- [x] Localhost
- [x] EC2 (using your own load balancer)
- [ ] EC2 (using [Caddy's load balancer](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy))
- [ ] Multiple Docker instance setup (for any cloud provider)
- [ ] Kubernetes

## Dependencies

- [Git](https://github.com/git-guides/install-git)
- [Docker](https://docs.docker.com/engine/install/)

## Requirements

- MacOS or Linux (not tested on Windows)
- License Key (available at https://selfhost.quadratic-preview.com)
- The following open ports: 80, 443, 3001, 3002, 3003, 4433, 4455, and 8000

## Installation

> **NOTE:** _Before installing, please create a license and copy the key at https://selfhost.quadratic-preview.com._

Quadratic can be installed via a single command:

```shell
curl -sSf https://raw.githubusercontent.com/quadratichq/quadratic-selfhost/main/init-local.sh -o init.sh && bash -i init.sh
```

This will download the initialization script, which will prompt for a license key in order to register Quadratic.

Additionally, the docker compose network will start (see [Starting](#Starting)). Please allow several minutes for the docker images to downloaded.

Refer to the [Stopping](#Stopping) section.

## Starting

Once the Quadratic is initialized, a single command is needed to start all of the images:

```shell
./start.sh
```

## Stopping

To stop running docker images, simply press `ctrl + c` if running in the foreground.

If running in the background, run the `stop.sh` script:

```shell
./stop.sh
```

## Creating an EC2 Instance

- Click on Launch and Instance from the main EC2 screen
- Select the Ubuntu option
- The minium size should be a t2.xlarge
- Either create a new security group with `Allow HTTPS traffic from the internet` or `Allow HTTP traffic from the internet` (not using certs) OR select an existing security group with this setting enabled
  - Open ports 80, 443, 3001, 3002, 3003, 4433, 4455, and 8000 for TCP traffic with 0.0.0.0/0 source
- Configure storage to 30GiB
- Click on the "Launch Instance" button

## Installing on Ubuntu

```shell
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo docker --version
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chown $USER /var/run/docker.sock
sudo systemctl enable docker
sudo systemctl start docker
curl -sSf https://raw.githubusercontent.com/quadratichq/quadratic-selfhost/main/init-aws.sh -o init.sh && bash -i init.sh
```

## Configuring SSL with AWS Cloudformation deployment

- When using the cloud formation template configure a domain or subdomain that you own and can create `A` DNS records in. For example with a subdomain
  `quadratic.example.com`
- Run the CloudFormation template and put in your license key and domain (or subdomain)
- Once the Template runs, go to outputs and copy the InstancePublicIp
- Create an `A` record `*.quadratic.example.com` where you prefix `*.` with the domain you configured Quadratic with.
