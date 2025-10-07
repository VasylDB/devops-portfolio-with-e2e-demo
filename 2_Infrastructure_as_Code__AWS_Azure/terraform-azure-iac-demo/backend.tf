terraform {
  backend "azurerm" {
    resource_group_name  = "iac-demo-bootstrap-rg"
    storage_account_name = "iacdemobootstrap"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
