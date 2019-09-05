# Copyright (c) 2019 Cable Television Laboratories, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Azure Credentials
//provider "azurerm" {
//  subscription_id = var.subscription_id
//  client_id = var.client_id
//  client_secret = var.client_secret
//  tenant_id = var.tenant_id
//  environment = "public"
//}

resource "azurerm_resource_group" "snaps-ci" {
  location = var.location
  name = "snaps-ci-res-grp-${var.build_id}"
}

resource "azurerm_virtual_network" "snaps-ci-net" {
  name = "snaps-ci-net-${var.build_id}"
  address_space = ["10.1.0.0/16"]
  location = azurerm_resource_group.snaps-ci.location
  resource_group_name = azurerm_resource_group.snaps-ci.name
}

resource "azurerm_subnet" "snaps-ci-subnet" {
  name = "snaps-ci-subnet-${var.build_id}"
  virtual_network_name = azurerm_virtual_network.snaps-ci-net.name
  resource_group_name = azurerm_resource_group.snaps-ci.name
  address_prefix = "10.1.0.0/24"
}

resource "azurerm_public_ip" "snaps-ci-pub-ip" {
  name = "snaps-ci-${var.build_id}"
  location = azurerm_resource_group.snaps-ci.location
  resource_group_name = azurerm_resource_group.snaps-ci.name
  allocation_method = "Static"
}

resource "azurerm_network_interface" "snaps-ci-nic" {
  name                = "snaps-ci-${var.build_id}-nic"
  location = azurerm_resource_group.snaps-ci.location
  resource_group_name = azurerm_resource_group.snaps-ci.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = azurerm_subnet.snaps-ci-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.snaps-ci-pub-ip.id
  }
}

resource "azurerm_virtual_machine" "snaps-ci-host" {
  name = "snaps-ci-host-${var.build_id}"
  location = azurerm_resource_group.snaps-ci.location
  resource_group_name = azurerm_resource_group.snaps-ci.name
  network_interface_ids = [azurerm_network_interface.snaps-ci-nic.id]
  vm_size = var.vm_size

  os_profile {
    admin_username = "ubuntu"
    admin_password = "Cable123"
    computer_name = "snaps-ci-host"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      key_data = file(var.public_key_file)
      path = "/home/${var.sudo_user}/.ssh/authorized_keys"
    }
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = "snaps-ci-disk-${var.build_id}"
    disk_size_gb = var.volume_size
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    Name = "snaps-ci-build-${var.build_id}"
  }

  # Used to ensure host is really up before attempting to apply ansible playbooks
  provisioner "remote-exec" {
    inline = [
      "sudo apt install python -y"
    ]
  }

  # Remote connection info for remote-exec
  connection {
    host = azurerm_public_ip.snaps-ci-pub-ip.ip_address
    type     = "ssh"
    user     = var.sudo_user
    private_key = file(var.private_key_file)
    timeout = "15m"
  }
}
