resource "azurerm_resource_group" "rg" {
  name     = "var.resource_group_name"
  location = "westus"
  
}

# Local values for storage account name sanitization
locals {
  # If regex sanitization is enabled and regexreplace is supported, strip everything not a-z0-9.
  # Otherwise fall back to removing hyphens only.
  sanitized_prefix = var.use_regex_sanitizer ? (
    try(regexreplace(lower(var.prefix), "[^a-z0-9]", ""), replace(lower(var.prefix), "-", ""))
  ) : replace(lower(var.prefix), "-", "")
  truncated_prefix = substr(local.sanitized_prefix, 0, 12)
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myTFvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet inside the virtual network
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "tf_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "tf-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "tf-security-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "tf-network-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  # Build a compliant storage account name:
  # - only lowercase letters and numbers
  # - between 3 and 24 characters
  # sanitize var.prefix, remove non-alphanumerics, lowercase it, and truncate to 12 chars.
  # Then append 'diag' and an 8-char hex from random_id (byte_length = 4) => total max length 24.
  # Construct name by lowercasing and removing hyphens from the prefix, truncating to 12 chars,
  # then appending 'diag' and the 8-char hex from random_id (byte_length = 4).
  # If the sanitized prefix becomes empty, fallback to 'diag<hex>'.
  name = local.sanitized_prefix == "" ? format("diag%s", random_id.random_id.hex) : format("%sdiag%s", local.truncated_prefix, random_id.random_id.hex)
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

} 


# Create virtual machine
resource "azurerm_windows_virtual_machine" "main" {
  name                  = "${var.prefix}-windows-vm"
  admin_username        = "azure-tf-user"
  admin_password        = random_password.password.result
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }


  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}


# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 4
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}