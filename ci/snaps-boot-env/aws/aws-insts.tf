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

# AWS EC2 Instances
resource "aws_instance" "snaps-ci-host" {
  ami = var.base_ami
  instance_type = var.instance_type
  key_name = aws_key_pair.snaps-ci-pk.key_name
  availability_zone = var.availability_zone

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "snaps-ci-build-${var.build_id}"
  }

  security_groups = [aws_security_group.snaps-ci.name]
  associate_public_ip_address = true

  # Used to ensure host is really up before attempting to apply ansible playbooks
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install python2.7 -y",
      "sudo rm /usr/bin/python",
      "sudo ln /usr/bin/python2.7 /usr/bin/python"
    ]
  }

  # Remote connection info for remote-exec
  connection {
    host = self.public_ip
    type     = "ssh"
    user     = var.sudo_user
    private_key = file(var.private_key_file)
    timeout = "15m"
  }
}
