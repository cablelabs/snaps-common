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
import numbers


class ProxySettings:
    """
    Represents the information required for sending traffic (HTTP & SSH)
    through a proxy
    """

    def __init__(self, **kwargs):
        """
        Constructor
        :param host: the HTTP proxy host
        :param port: the HTTP proxy port
        :param https_host: the HTTPS proxy host (defaults to host)
        :param https_port: the HTTPS proxy port (defaults to port)
        :param ssh_proxy_cmd: the SSH proxy command string (optional)
        """
        self.host = kwargs.get('host')
        self.port = kwargs.get('port')
        if self.port and isinstance(self.port, numbers.Number):
            self.port = str(self.port)

        self.https_host = kwargs.get('https_host', self.host)
        self.https_port = kwargs.get('https_port', self.port)
        if self.https_port and isinstance(self.https_port, numbers.Number):
            self.https_port = str(self.https_port)

        self.ssh_proxy_cmd = kwargs.get('ssh_proxy_cmd')

        if not self.host or not self.port:
            raise ProxySettingsError('host & port are required')

    def __str__(self):
        """Converts object to a string"""
        return 'ProxySettings - host=' + str(self.host) + \
               ', port=' + str(self.port) + \
               ', ssh_proxy_cmd=' + str(self.ssh_proxy_cmd)


class ProxySettingsError(Exception):
    """
    Exception to be thrown when an OSCred are invalid
    """
