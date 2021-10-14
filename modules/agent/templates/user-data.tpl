#!/usr/bin/env bash
set -x
exec > >(tee /var/log/tf-user-data.log|logger -t user-data ) 2>&1

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT $0: $1"
}

logger "Running"

sudo apt-get update

sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
 "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install docker-ce -y

sudo usermod -aG docker $(whoami)
sudo gpasswd -a $(whoami) docker
sudo systemctl enable docker
sudo systemctl start docker

sudo docker pull hashicorp/tfc-agent:latest

sudo docker run -e TFC_AGENT_TOKEN=${TFC_AGENT_TOKEN} -e TFC_AGENT_NAME=${TFC_AGENT_NAME} hashicorp/tfc-agent

logger "Complete"
