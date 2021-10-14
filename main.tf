provider "tfe" {
}

data "tfe_organization" "org" {
  name = var.org_name
}

resource "tfe_agent_pool" "agent-pool" {
  name         = "${var.namespace}-pool"
  organization = data.tfe_organization.org.name
}

resource "tfe_agent_token" "agent-token" {
  agent_pool_id = tfe_agent_pool.agent-pool.id
  description   = "Created by Terraform"
}

module "agents" {
  source  = "./modules/agent"
  # insert required variables here
  TFC_AGENT_TOKEN = tfe_agent_token.agent-token.token
}

output "agents" {
  value = module.agents.eip
}