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

from collections import namedtuple

import os
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.inventory.manager import InventoryManager
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager

__author__ = 'spisarski'

logger = logging.getLogger('ansible_utils')


def apply_playbook(playbook_path, hosts_inv=None, host_user=None,
                   ssh_priv_key_file_path=None, password=None, variables=None,
                   proxy_setting=None, inventory_file=None):
    """
    Executes an Ansible playbook to the given host
    :param playbook_path: the (relative) path to the Ansible playbook
    :param hosts_inv: a list of hostnames/ip addresses to which to apply the
                      Ansible playbook (not required when PB is configured for
                      localhost)
    :param host_user: A user for the host instances (must be a password-less
                      sudo user if playbook has "sudo: yes") (not required when
                      PB is configured for localhost)
    :param ssh_priv_key_file_path: the file location of the ssh key. Required
                                   if password is None (not required when PB is
                                   configured for localhost)
    :param password: the file location of the ssh key. Required if
                     ssh_priv_key_file_path is None (not required when PB is
                     configured for localhost)
    :param variables: a dictionary containing any substitution variables needed
                      by the Jinga 2 templates
    :param proxy_setting: instance of os_credentials.ProxySettings class
    :param inventory_cfg: dict specifying host/groups where the key is group
                          name and the value is a list of hosts
    :raises AnsibleException when the return code from the Ansible library is
            not 0
    :return: the return code from the Ansible library only when 0.
             Implementation now raises an exception otherwise
    """
    if not os.path.isfile(playbook_path):
        raise AnsibleException(
            'Requested playbook not found - ' + playbook_path)
    else:
        logger.info('Applying playbook [%s] with variables - %s',
                    playbook_path, variables)

    pk_file_path = None
    if ssh_priv_key_file_path:
        pk_file_path = os.path.expanduser(ssh_priv_key_file_path)
        if not password:
            if not os.path.isfile(pk_file_path):
                raise AnsibleException(
                    'Requested private SSH key not found - ' + pk_file_path)

    passwords = None
    if password:
        passwords = {'conn_pass': password, 'become_pass': password}

    import ansible.constants
    ansible.constants.HOST_KEY_CHECKING = False

    loader = DataLoader()
    if inventory_file:
        inventory = InventoryManager(loader=loader, sources=inventory_file)
        connection = 'ssh'
    elif hosts_inv:
        inventory = InventoryManager(loader=loader)
        for host in hosts_inv:
            inventory.add_host(host=host, group='ungrouped')
        connection = 'ssh'
    else:
        loader = DataLoader()
        inventory = InventoryManager(loader=loader)
        connection = 'local'

    variable_manager = VariableManager(loader=loader, inventory=inventory)

    if variables:
        variable_manager.extra_vars = variables

    ssh_extra_args = None
    if proxy_setting and proxy_setting.ssh_proxy_cmd:
        ssh_extra_args = '-o ProxyCommand=\'%s\'' % proxy_setting.ssh_proxy_cmd

    options = namedtuple(
        'Options', ['listtags', 'listtasks', 'listhosts', 'syntax',
                    'connection', 'module_path', 'forks', 'remote_user',
                    'private_key_file', 'ssh_common_args', 'ssh_extra_args',
                    'become', 'become_method', 'become_user', 'verbosity',
                    'check', 'timeout', 'diff'])

    ansible_opts = options(
        listtags=False, listtasks=False, listhosts=False, syntax=False,
        connection=connection, module_path=None, forks=100,
        remote_user=host_user, private_key_file=pk_file_path,
        ssh_common_args=None, ssh_extra_args=ssh_extra_args, become=None,
        become_method=None, become_user=None, verbosity=11111, check=False,
        timeout=30, diff=None)

    logger.debug('Setting up Ansible Playbook Executor for playbook - ' +
                 playbook_path)
    executor = PlaybookExecutor(
        playbooks=[playbook_path],
        inventory=inventory,
        variable_manager=variable_manager,
        loader=loader,
        options=ansible_opts,
        passwords=passwords)

    logger.debug('Executing Ansible Playbook - ' + playbook_path)
    ret_val = executor.run()

    if ret_val != 0:
        raise AnsibleException(
            'Error applying playbook [{}] with value [{}] using the connection'
            ' type of [{}]'.format(
                playbook_path, ret_val, connection))

    return ret_val


class AnsibleException(Exception):
    """
    Exception when calls to the Keystone client cannot be served properly
    """
