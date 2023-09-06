terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

   subscription_id = <your-subscription-id> 
   tenant_id       = <your-tenant-id>  
}
provider "null" {
  version = "~> 3.0"
}
provider "github" {
  token =  <your-github-token> 
}

variable "zip_file_name" {
  description = "Name of the zip file to be created"
  type        = string
  default     = "fetched_repo.zip"
}

resource "null_resource" "git_fetch_and_zip" {
  # Triggers the provisioner whenever the repository URL or branch changes
  triggers = {
    git_repository = "testing"
    git_branch     = "master"
  }
  provisioner "local-exec" {
    command = "git clone <PATH-TO-GITHUB-REPO>"
    working_dir = "/home/USER"
  }
  provisioner "local-exec" {
    command = "zip -r ${var.zip_file_name} ./*"
    working_dir = "/home/USER"
  }
}

# Azure Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "testingstorageaccount"
  resource_group_name      = <resource-grp-name>
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Azure Storage Container
resource "azurerm_storage_container" "example" {
  name                  =  <container_name>
  storage_account_name  =  <azurerm-storage-account-name>
  container_access_type = "private"
}

# Azure Storage Blob
resource "azurerm_storage_blob" "example" {
  name                   = "repo_contents.zip"
  storage_account_name   = <azurerm-storage-account-name>
  storage_container_name = <storage-container-name>
  type                   = "Block"
  #source_content_type   = "application/zip"
  source             = "fetched_repo.zip"
}
