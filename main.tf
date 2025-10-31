module "terraform_cloud_workspace" {
  source                  = "./modules/tfworkspace"
  workspace_name          = local.terraform_cloud_workspace_name
  organisation            = var.terraform_cloud_organisation
  project_name            = var.terraform_cloud_user_project
  arm_subscription_id     = module.lz_vending.subscription_id
  arm_tenant_id           = data.azuread_client_config.current.tenant_id
  tfc_azure_run_client_id = module.lz_vending.umi_client_id
  resource_group_name     = [ for key, resource_group in var.resource_groups : resource_group.name if resource_group.primary ][0]
}

module "lz_vending" {
  source  = "Azure/lz-vending/azurerm"
  version = "6.0.0"
  location = "germanywestcentral"
  subscription_id = "969a5e2c-b2ac-4cd2-b726-a204e2f1c1ef"
  subscription_management_group_association_enabled = true
  subscription_management_group_id = "sub-vending-demo2"

  # resource groups
  resource_group_creation_enabled = true
  resource_groups                 = { for key, resource_group in var.resource_groups :key => {
      name     = resource_group.name
      location = resource_group.location
    }
  }
}

module "github" {
  source                         = "./modules/github"
  repository_name                = local.github_repository_name
  repository_description         = local.github_repository_name
  repository_organisation        = var.repository_organisation
  template_organisation          = var.persona_template_organisation
  template_repository            = var.persona_template_repository
  terraform_cloud_organisation   = var.terraform_cloud_organisation
  terraform_cloud_workspace_name = local.terraform_cloud_workspace_name
  terraform_cloud_access_token   = module.terraform_cloud_workspace.team_api_token
}
