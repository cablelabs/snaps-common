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

# Required Variables
variable "subscription_id" {default = "ffc5d93a-8a85-4c42-8c33-7d0d762e852d"}
variable "client_id" {default = "c4395b75-49cc-422c-bc95-c7d51aef5d46"}
variable "client_secret" {default = "345e0a3b-c816-11e9-8c5d-74e5f934bda9"}
variable "tenant_id" {default = "ce4fbcd1-1d81-4af0-ad0b-2998c441e160"}

variable "build_id" {}

variable "resource_group_name" {default = "snaps-boot-ci"}

# Variables that are recommended to change as they won't work in all envs
variable "node_1_cpus" {default = "2"}
variable "node_2_cpus" {default = "2"}
variable "node_3_cpus" {default = "2"}
variable "node_1_memory" {default = "4194304"}
variable "node_2_memory" {default = "4194304"}
variable "node_3_memory" {default = "4194304"}
variable "public_key_file" {default = "~/.ssh/id_rsa.pub"}
variable "private_key_file" {default = "~/.ssh/id_rsa"}

variable "vm_host_pub_key" {default = "~/.ssh/id_rsa.pub"}
variable "vm_host_priv_key" {default = "~/.ssh/id_rsa"}

variable "base_ami" {default = "ami-06f2f779464715dc5"}
variable "build_server_image_url" {default = "https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"}

variable "pause_sec" {default = "30"}

# Playbook Constants
variable "ANSIBLE_CMD" {default = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook"}
variable "SETUP_HOST_PROXY" {default = "../playbooks/setup_proxy.yaml"}
variable "CLEANUP" {default = "../playbooks/cleanup.yaml"}
variable "SETUP_KVM_DEPENDENCIES" {default = "../playbooks/kvm/dependencies.yaml"}
variable "SETUP_KVM_NETWORKS" {default = "../playbooks/kvm/networks.yaml"}
variable "SETUP_KVM_SERVERS" {default = "../playbooks/kvm/servers.yaml"}

# Variables for snaps-boot-env images with defaults to be found in boot-env.tfvars
variable "sudo_user" {}

//variable "availability_zone" {}
//variable "instance_type" {}
variable "vm_size" {}
variable "location" {}
variable "volume_size" {}
variable "netmask" {}
variable "build_ip_prfx" {}
variable "build_ip_bits" {}
variable "build_ip_suffix" {}
variable "build_net_name" {}
variable "priv_ip_prfx" {}
variable "priv_net_name" {}
variable "admin_ip_prfx" {}
variable "admin_net_name" {}
variable "pub_ip_prfx" {}
variable "pub_net_name" {}
variable "build_nic" {}
variable "build_vm_name" {}
variable "build_password" {}
variable "build_mac_0" {}
variable "build_mac_1" {}
variable "build_mac_2" {}
variable "build_mac_3" {}
variable "node_1_name" {}
variable "node_2_name" {}
variable "node_3_name" {}
variable "node_1_mac_1" {}
variable "node_1_mac_2" {}
variable "node_1_mac_3" {}
variable "node_2_mac_1" {}
variable "node_2_mac_2" {}
variable "node_2_mac_3" {}
variable "node_3_mac_1" {}
variable "node_3_mac_2" {}
variable "node_3_mac_3" {}
variable "node_1_suffix" {}
variable "node_2_suffix" {}
variable "node_3_suffix" {}
variable "proxy_port" {}
variable "ngcacher_proxy_port" {}
variable "pxe_pass" {}
variable "hosts_yaml_path" {}
