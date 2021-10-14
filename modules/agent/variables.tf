
data "http" "myipaddr" {
    url = "http://ipv4.icanhazip.com"
}
locals {
   host_access_ip = ["${chomp(data.http.myipaddr.body)}/32"]

   common_tags = {
    Name      = var.namespace
    owner     = var.owner
    se-region = var.region
    terraform = true
    purpose   = var.purpose
    ttl       = var.TTL
  }
}
variable "region" {
  description = "The region to create resources."
  default     = "eu-west-2"
}

variable "instances" {
  description = "number of TF Agent instances"
  default     = "2"
}

variable "purpose" {
  default     = "demo"
}

variable "namespace" {
  description = <<EOH
this is the differantiates different deployment on the same subscription, every cluster should have a different value
EOH
  default = "andre_remote_agent"
}



variable "owner" {
description = "IAM user responsible for lifecycle of cloud resources used for training"
default = "andre"
}

variable "created-by" {
description = "Tag used to identify resources created programmatically by Terraform"
default = "Terraform"
}

variable "sleep-at-night" {
description = "Tag used by reaper to identify resources that can be shutdown at night"
default = false
}

variable "TTL" {
description = "Hours after which resource expires, used by reaper. Do not use any unit. -1 is infinite."
default = "240"
}

variable "vpc_cidr_block" {
description = "The top-level CIDR block for the VPC."
default = "10.1.0.0/16"
}

variable "cidr_blocks" {
description = "The CIDR blocks to create the workstations in."
default = ["10.1.1.0/24", "10.1.2.0/24"]
}


variable "instance_type_worker" {
description = "The type(size) of data servers (consul, nomad, etc)."
default = "t2.large"
}

# variable "host_access_ip" {
#   description = "CIDR blocks allowed to connect via SSH on port 22"
#   default = []
# }

variable "ssh_public_key" {
    description = "The contents of the SSH public key to use for connecting to the cluster."
}


variable "ami" {
  default = "ami-6b3fd60c"
}


variable "TFC_AGENT_TOKEN" {
}

variable "TFC_AGENT_NAME" {
  default = "andre-tfc-agent"
}

