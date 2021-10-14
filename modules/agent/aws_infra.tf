provider "aws" {
  region  = var.region
}


resource "aws_vpc" "agent_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

    tags = local.common_tags
}

resource "aws_internet_gateway" "agent_ig" {
  vpc_id = aws_vpc.agent_vpc.id

    tags = local.common_tags
}

resource "aws_route_table" "agent" {
  vpc_id = aws_vpc.agent_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.agent_ig.id
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "agent_subnet" {
  count                   = length(var.cidr_blocks)
  vpc_id                  = aws_vpc.agent_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.cidr_blocks[count.index]
  map_public_ip_on_launch = true

    tags = local.common_tags
}

resource "aws_route_table_association" "agent" {
  count          = length(var.cidr_blocks)
  route_table_id = aws_route_table.agent.id
  subnet_id      = element(aws_subnet.agent_subnet.*.id, count.index)
}

resource "aws_security_group" "agent_sg" {
  name_prefix = var.namespace
  vpc_id      = aws_vpc.agent_vpc.id

  # SSH access if host_access_ip has CIDR blocks
  dynamic "ingress" {
    for_each = local.host_access_ip
    content {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = [ "${ingress.value}" ]
    }
  }

# HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


#HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.namespace}-${var.owner}"
  public_key = file(var.ssh_public_key)
}


data "aws_iam_policy_document" "agent-policy" {

  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
      "s3:*",
      "iam:PassRole",
      "iam:ListRoles",
      "cloudwatch:PutMetricData",
      "ds:DescribeDirectories",
      "logs:*",
      "sts:GetCallerIdentity",
      "sts:AssumeRole",
      "iam:GetRole",
      "iam:GetInstanceProfile", 
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey" 
    ]

    resources = ["*"]
  }

}


resource "aws_iam_policy" "agent-policy" {
  name        = "${var.namespace}-agent-iam-policy"
  policy = data.aws_iam_policy_document.agent-policy.json

# tags = local.common_tags
}

resource "aws_iam_role" "agent-role" {
  name               = "${var.namespace}-agent-role"
  assume_role_policy = file("modules/agent/templates/assume-role.json")

  # tags = local.common_tags
}

resource "aws_iam_policy_attachment" "agent-role" {
  name       = "${var.namespace}-agent-policy-attach"
  roles      = [aws_iam_role.agent-role.name]
  policy_arn = aws_iam_policy.agent-policy.arn

}