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

from mock import patch

from snaps_common.ssh import ssh_utils

logging.basicConfig(level=logging.DEBUG)


class SSHUtilsTests(unittest.TestCase):
    """
    Mocked unit tests for snaps_common.utils.ssh_utils.py
    """

    @patch('paramiko.SSHClient.connect')
    def test_ssh_client_minimal(self, m1):
        """
        Initial test to ensure main code path does not have any syntax or
        import errors when calling with the minimal parameters
        :return:
        """
        self.assertIsNotNone(m1)
        client = ssh_utils.ssh_client('foo', 'user')
        self.assertIsNotNone(client)
