# Copyright (c) 2018 Cable Television Laboratories, Inc. ("CableLabs")
#                    and others.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import logging
import os

import paramiko

__author__ = 'spisarski'

logger = logging.getLogger('ssh_utils')


def ssh_client(ip, user, private_key_filepath=None, password=None,
               proxy_settings=None):
    """
    Retrieves and attemts an SSH connection
    :param ip: the IP of the host to connect
    :param user: the user with which to connect
    :param private_key_filepath: when None, password is required
    :param password: when None, private_key_filepath is required
    :param proxy_settings: instance of os_credentials.ProxySettings class
                           (optional)
    :return: the SSH client if can connect else false
    """
    logger.debug('Retrieving SSH client')
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.MissingHostKeyPolicy())

    try:
        proxy_cmd = None
        if proxy_settings and proxy_settings.ssh_proxy_cmd:
            proxy_cmd_str = str(proxy_settings.ssh_proxy_cmd.replace('%h', ip))
            proxy_cmd_str = proxy_cmd_str.replace("%p", '22')
            proxy_cmd = paramiko.ProxyCommand(proxy_cmd_str)

        pk_abs_path = None
        if not password and private_key_filepath:
            pk_abs_path = os.path.expanduser(private_key_filepath)

        ssh.connect(
            ip, username=user, key_filename=pk_abs_path, password=password,
            sock=proxy_cmd)
        logger.info('Obtained SSH connection to %s', ip)
        return ssh
    except Exception as e:
        logger.debug('Unable to connect via SSH with message - ' + str(e))
