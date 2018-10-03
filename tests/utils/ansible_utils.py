# Copyright 2018 ARICENT HOLDINGS LUXEMBOURG SARL and Cable Television
# Laboratories, Inc.
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
import logging
import unittest

import pkg_resources
from mock import patch

from snaps_common.utils import ansible_utils

logging.basicConfig(level=logging.DEBUG)


class AnsibleUtilsTests(unittest.TestCase):
    """
    Mocked unit tests for snaps_common.utils.ansible_utils.py#apply_playbook()
    to ensure the call to
    ansible.executor.playbook_executor.PlaybookExecutor#run() is getting
    properly formed
    """

    def setUp(self):
        self.pb_loc = pkg_resources.resource_filename(
            'tests.utils.playbooks', 'simple_playbook.yaml')

    @patch('ansible.executor.playbook_executor.PlaybookExecutor.run',
           return_value=0)
    def test_apply_playbook_minimal(self, m1):
        """
        Initial test to ensure main code path does not have any syntax or
        import errors when calling with the minimal parameters
        :return:
        """
        self.assertIsNotNone(m1)
        ansible_utils.apply_playbook(self.pb_loc)

    @patch('ansible.executor.playbook_executor.PlaybookExecutor.run',
           return_value=0)
    @patch('os.path.expanduser', return_value='/foo/bar')
    def test_apply_playbook_main(self, m1, m2):
        """
        Initial test to ensure main code path does not have any syntax or
        import errors when calling with parameters that are mostly used
        :return:
        """
        self.assertIsNotNone(m1)
        self.assertIsNotNone(m2)
        ansible_utils.apply_playbook(
            self.pb_loc, hosts_inv=['foo', 'bar'], host_user='user',
            password='password', variables={'foo': 'bar'})
