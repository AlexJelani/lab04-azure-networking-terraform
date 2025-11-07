# ═══════════════════════════════════════════════════════
# setup-backend.tf - Creates Azure Storage for Terraform state
# Run this ONCE to create the backend storage
# ═══════════════════════════════════════════════════════

resource "random_id" "storage_suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "tfstate" {
  name     = "terraform-state-rg"
  location = "East US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = {
    purpose = "terraform-state"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Output the backend configuration
output "backend_config" {
  value = <<EOF

Add this to your main.tf terraform block:

backend "azurerm" {
  resource_group_name  = "${azurerm_resource_group.tfstate.name}"
  storage_account_name = "${azurerm_storage_account.tfstate.name}"
  container_name       = "${azurerm_storage_container.tfstate.name}"
  key                  = "lab04.terraform.tfstate"
}

EOF
}