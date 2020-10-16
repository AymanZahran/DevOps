#Create Resource Group
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags = {
        environment = "Terraform Deploy"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Deploy"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create Public IP
resource "azurerm_public_ip" "Master01_PublicIP" {
    name                         = "Master01_PublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"
    
    tags = {
        environment = "Terraform Deploy"
    }
}

resource "azurerm_public_ip" "Node01_PublicIP" {
    name                         = "Node01_PublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"
    
    tags = {
        environment = "Terraform Deploy"
    }
}

resource "azurerm_public_ip" "Node02_PublicIP" {
    name                         = "Node02_PublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"
    
    tags = {
        environment = "Terraform Deploy"
    }
}

# Create NSG
resource "azurerm_network_security_group" "Master01_NSG" {
    name                = "Master01_NSG"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Deploy"
    }
}


resource "azurerm_network_security_group" "Node01_NSG" {
    name                = "Node01_NSG"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Deploy"
    }
}


resource "azurerm_network_security_group" "Node02_NSG" {
    name                = "Node02_NSG"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Deploy"
    }
}

# Create NIC
resource "azurerm_network_interface" "Master01_NIC" {
    name                      = "Master01_NIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.Master01_PublicIP.id
    }

    tags = {
        environment = "Terraform Deploy"
    }
}


resource "azurerm_network_interface" "Node01_NIC" {
    name                      = "Node01_NIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.Node01_PublicIP.id
    }

    tags = {
        environment = "Terraform Deploy"
    }
}

resource "azurerm_network_interface" "Node02_NIC" {
    name                      = "Node02_NIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.Node02_PublicIP.id
    }

    tags = {
        environment = "Terraform Deploy"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "Master01_NSG_NIC" {
    network_interface_id      = azurerm_network_interface.Master01_NIC.id
    network_security_group_id = azurerm_network_security_group.Master01_NSG.id
}

resource "azurerm_network_interface_security_group_association" "Node01_NSG_NIC" {
    network_interface_id      = azurerm_network_interface.Node01_NIC.id
    network_security_group_id = azurerm_network_security_group.Node01_NSG.id
}

resource "azurerm_network_interface_security_group_association" "Node02_NSG_NIC" {
    network_interface_id      = azurerm_network_interface.Node02_NIC.id
    network_security_group_id = azurerm_network_security_group.Node02_NSG.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Deploy"
    }
}

# Create (and display) an SSH key
# resource "tls_private_key" "example_ssh" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }
# output "tls_private_key" { value = "${tls_private_key.example_ssh.private_key_pem}" }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "Master01" {
    name                  = "Master01"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.Master01_NIC.id]
    size                  = "Standard_D2s_v3"

    os_disk {
        name              = "Master_OS_Disk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "8_2-gen2"
        version   = "latest"
    }

    computer_name  = "Master01"
    admin_username = "sysadmin"
    admin_password = "P@ssw0rdP@ssw0rd"
    disable_password_authentication = false
        
    # admin_ssh_key {
    #     username       = "sysadmin"
    #     #public_key     = tls_private_key.example_ssh.public_key_openssh
        
    # }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Deploy"
    }
}

resource "azurerm_linux_virtual_machine" "Node01" {
    name                  = "Node01"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.Node01_NIC.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "Node01_OS_Disk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "8_2-gen2"
        version   = "latest"
    }

    computer_name  = "Node01"
    admin_username = "sysadmin"
    admin_password = "P@ssw0rdP@ssw0rd"
    disable_password_authentication = false
        
    # admin_ssh_key {
    #     username       = "sysadmin"
    #     #public_key     = tls_private_key.example_ssh.public_key_openssh
        
    # }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Deploy"
    }
}

resource "azurerm_linux_virtual_machine" "Node02" {
    name                  = "Node02"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.Node02_NIC.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "Node02_OS_Disk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "8_2-gen2"
        version   = "latest"
    }

    computer_name  = "Node02"
    admin_username = "sysadmin"
    admin_password = "P@ssw0rdP@ssw0rd"
    disable_password_authentication = false
        
    # admin_ssh_key {
    #     username       = "sysadmin"
    #     #public_key     = tls_private_key.example_ssh.public_key_openssh
        
    # }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Deploy"
    }
}

