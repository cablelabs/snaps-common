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

# Call ensure SSH key has correct permissions
resource "null_resource" "snaps-ci-pk-setup" {
  depends_on = [azurerm_virtual_machine.snaps-ci-host]
  provisioner "local-exec" {
    command = "chmod 600 ${var.private_key_file}"
  }
}

locals {
  remote_pub_key_file = "/tmp/${var.build_id}-remote-pk.pub"
  remote_priv_key_file = "/tmp/${var.build_id}-remote-pk"
}

# Call ensure SSH key has correct permissions
resource "null_resource" "snaps-ci-remote-setup" {
  depends_on = [null_resource.snaps-ci-pk-setup]
  provisioner "remote-exec" {
    inline = [
      "yes y | ssh-keygen -t rsa -N '' -f ${var.vm_host_priv_key}",
    ]
  }
  connection {
    host = azurerm_public_ip.snaps-ci-pub-ip.ip_address
    type     = "ssh"
    user     = var.sudo_user
    private_key = file(var.private_key_file)
  }
}

# Call ensure SSH key has correct permissions
resource "null_resource" "snaps-ci-get-host-pub-key" {
  depends_on = [null_resource.snaps-ci-remote-setup]
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ${var.sudo_user}@${azurerm_public_ip.snaps-ci-pub-ip.ip_address}:~/.ssh/id_rsa.pub ${local.remote_pub_key_file}"
  }
}

# Call ensure SSH key has correct permissions
resource "null_resource" "snaps-ci-get-host-priv-key" {
  depends_on = [null_resource.snaps-ci-remote-setup]
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ${var.sudo_user}@${azurerm_public_ip.snaps-ci-pub-ip.ip_address}:~/.ssh/id_rsa ${local.remote_priv_key_file}"
  }
}

# Call ansible scripts to squid proxy server on host VM
resource "null_resource" "snaps-ci-proxy-setup" {
  depends_on = [null_resource.snaps-ci-get-host-pub-key]

  # Install KVM dependencies
  provisioner "local-exec" {
    command = <<EOT
${var.ANSIBLE_CMD} -u ${var.sudo_user} \
-i ${azurerm_public_ip.snaps-ci-pub-ip.ip_address}, \
${var.SETUP_HOST_PROXY} \
--key-file ${var.private_key_file} \
--extra-vars "\
proxy_port=${var.proxy_port}
"\
EOT
  }
}

# Call ansible scripts to setup KVM
resource "null_resource" "snaps-ci-kvm-setup" {
  depends_on = [null_resource.snaps-ci-proxy-setup]

  # Install KVM dependencies
  provisioner "local-exec" {
    command = <<EOT
${var.ANSIBLE_CMD} -u ${var.sudo_user} \
-i ${azurerm_public_ip.snaps-ci-pub-ip.ip_address}, \
${var.SETUP_KVM_DEPENDENCIES} \
--key-file ${var.private_key_file} \
EOT
  }
}

# Call ansible scripts to setup KVM networks
resource "null_resource" "snaps-ci-network-setup" {
  depends_on = [null_resource.snaps-ci-kvm-setup]
  # Create KVM networks
  provisioner "local-exec" {
    command = <<EOT
${var.ANSIBLE_CMD} -u ${var.sudo_user} \
-i ${azurerm_public_ip.snaps-ci-pub-ip.ip_address}, \
${var.SETUP_KVM_NETWORKS} \
--key-file ${var.private_key_file} \
--extra-vars "\
build_ip_prfx=${var.build_ip_prfx}
build_vm_name=${var.build_vm_name}
build_mac_1=${var.build_mac_1}
build_vm_ip=${var.build_ip_prfx}.${var.build_ip_suffix}
build_net_name=${var.build_net_name}
priv_ip_prfx=${var.priv_ip_prfx}
priv_net_name=${var.priv_net_name}
admin_ip_prfx=${var.admin_ip_prfx}
admin_net_name=${var.admin_net_name}
pub_ip_prfx=${var.pub_ip_prfx}
pub_net_name=${var.pub_net_name}
netmask=${var.netmask}
"\
EOT
  }
}

# Call ansible scripts to setup KVM servers
resource "null_resource" "snaps-ci-server-setup" {
  depends_on = [null_resource.snaps-ci-network-setup,
                null_resource.snaps-ci-get-host-pub-key]

  # Setup KVM on the VM to create VMs on it for testing snaps-ci
  provisioner "local-exec" {
    command = <<EOT
${var.ANSIBLE_CMD} -u ${var.sudo_user} \
-i ${azurerm_public_ip.snaps-ci-pub-ip.ip_address}, \
${var.SETUP_KVM_SERVERS} \
--key-file ${var.private_key_file} \
--extra-vars "\
build_img_url=${var.build_server_image_url }
target_user=${var.sudo_user}
build_net_name=${var.build_net_name}
priv_net_name=${var.priv_net_name}
priv_ip_prfx=${var.priv_ip_prfx}
admin_net_name=${var.admin_net_name}
admin_ip_prfx=${var.admin_ip_prfx}
pub_net_name=${var.pub_net_name}
pub_ip_prfx=${var.pub_ip_prfx}
build_vm_name=${var.build_vm_name}
build_password=${var.build_password}
build_public_key_file=${local.remote_pub_key_file}
local_public_key='${file(var.public_key_file)}'
build_ip_prfx=${var.build_ip_prfx}
build_ip_sfx=${var.build_ip_suffix}
build_ip_bits=${var.build_ip_bits}
build_gateway=${var.build_ip_prfx}.1
build_nic_name=${var.build_nic}
build_mac_0=${var.build_mac_0}
build_mac_1=${var.build_mac_1}
build_mac_2=${var.build_mac_2}
build_mac_3=${var.build_mac_3}
node_1_name=${var.node_1_name}
node_2_name=${var.node_2_name}
node_3_name=${var.node_3_name}
node_1_cpus=${var.node_1_cpus}
node_2_cpus=${var.node_2_cpus}
node_3_cpus=${var.node_3_cpus}
node_1_memory=${var.node_1_memory}
node_2_memory=${var.node_2_memory}
node_3_memory=${var.node_3_memory}
node_1_mac_1=${var.node_1_mac_1}
node_1_mac_2=${var.node_1_mac_2}
node_1_mac_3=${var.node_1_mac_3}
node_2_mac_1=${var.node_2_mac_1}
node_2_mac_2=${var.node_2_mac_2}
node_2_mac_3=${var.node_2_mac_3}
node_3_mac_1=${var.node_3_mac_1}
node_3_mac_2=${var.node_3_mac_2}
node_3_mac_3=${var.node_3_mac_3}
proxy_host=${var.build_ip_prfx}.1
proxy_port=${var.proxy_port}
"\
EOT
  }
}

# Create SSH key on build server
resource "null_resource" "snaps-ci-gen-build-key" {
  depends_on = [null_resource.snaps-ci-server-setup]
  provisioner "local-exec" {
    command = <<EOT
ssh -o StrictHostKeyChecking=no \
-o ProxyCommand="ssh ${var.sudo_user}@${azurerm_public_ip.snaps-ci-pub-ip.ip_address} nc ${var.build_ip_prfx}.${var.build_ip_suffix} 22" \
${var.sudo_user}@${var.build_ip_prfx}.${var.build_ip_suffix} \
"ssh-keygen -t rsa -N '' -f /home/${var.sudo_user}/.ssh/id_rsa"
EOT
  }
}

resource "random_integer" "snaps-common-ip-prfx" {
  min = 101
  max = 254
}

# Inject build server SSH key into libvirt host
resource "null_resource" "snaps-ci-authorize-build-to-libvirthost" {
  depends_on = [null_resource.snaps-ci-gen-build-key]
  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no ${var.build_ip_prfx}.${var.build_ip_suffix}:~/.ssh/id_rsa.pub ~/build_pub_key",
      "touch ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys",
      "cat ~/build_pub_key >> ~/.ssh/authorized_keys",
      "ssh -o StrictHostKeyChecking=no ${var.sudo_user}@${var.build_ip_prfx}.${var.build_ip_suffix} 'sudo ip addr add ${var.build_ip_prfx}.${random_integer.snaps-common-ip-prfx.result}/24 dev ens3'",
      "sleep ${var.pause_sec}",
    ]
  }
  connection {
    host = azurerm_public_ip.snaps-ci-pub-ip.ip_address
    type = "ssh"
    user = var.sudo_user
    private_key = file(var.private_key_file)
  }
}

# Cleanup this hosts key from the build server
resource "null_resource" "snaps-ci-cleanup-build-auth-key" {
  depends_on = [null_resource.snaps-ci-authorize-build-to-libvirthost]

  # Install KVM dependencies
  provisioner "local-exec" {
    command = <<EOT
${var.ANSIBLE_CMD} -u ${var.sudo_user} \
-i ${var.build_ip_prfx}.${random_integer.snaps-common-ip-prfx.result}, \
${var.CLEANUP} \
--ssh-common-args="\
-o ProxyCommand='ssh ${var.sudo_user}@${azurerm_public_ip.snaps-ci-pub-ip.ip_address} nc ${var.build_ip_prfx}.${random_integer.snaps-common-ip-prfx.result} 22' \
-o StrictHostKeyChecking=no" \
--extra-vars "\
pub_key_to_clean='${file(var.public_key_file)}'
"\
EOT
  }
}
