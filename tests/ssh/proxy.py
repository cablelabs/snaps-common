import unittest

from snaps_common.ssh.proxy import ProxySettings, ProxySettingsError


class ProxySettingsUnitTests(unittest.TestCase):
    """
    Tests the construction of the ProxySettings class
    """

    def test_no_params(self):
        with self.assertRaises(ProxySettingsError):
            ProxySettings()

    def test_empty_kwargs(self):
        with self.assertRaises(ProxySettingsError):
            ProxySettings(**dict())

    def test_host_only(self):
        with self.assertRaises(ProxySettingsError):
            ProxySettings(host='foo')

    def test_host_only_kwargs(self):
        with self.assertRaises(ProxySettingsError):
            ProxySettings(**{'host': 'foo'})

    def test_port_only(self):
        with self.assertRaises(ProxySettingsError):
            ProxySettings(port=1234)

    def test_port_only_kwargs(self):
        with self.assertRaises(ProxySettingsError):
            ProxySettings(**{'port': 1234})

    def test_minimum(self):
        proxy_settings = ProxySettings(host='foo', port=1234)
        self.assertEqual('foo', proxy_settings.host)
        self.assertEqual('1234', proxy_settings.port)
        self.assertEqual('foo', proxy_settings.https_host)
        self.assertEqual('1234', proxy_settings.https_port)
        self.assertIsNone(proxy_settings.ssh_proxy_cmd)

    def test_minimum_kwargs(self):
        proxy_settings = ProxySettings(**{'host': 'foo', 'port': 1234})
        self.assertEqual('foo', proxy_settings.host)
        self.assertEqual('1234', proxy_settings.port)
        self.assertEqual('foo', proxy_settings.https_host)
        self.assertEqual('1234', proxy_settings.https_port)
        self.assertIsNone(proxy_settings.ssh_proxy_cmd)

    def test_all(self):
        proxy_settings = ProxySettings(
            host='foo', port=1234, https_host='bar', https_port=2345,
            ssh_proxy_cmd='proxy command')
        self.assertEqual('foo', proxy_settings.host)
        self.assertEqual('1234', proxy_settings.port)
        self.assertEqual('bar', proxy_settings.https_host)
        self.assertEqual('2345', proxy_settings.https_port)
        self.assertEqual('proxy command', proxy_settings.ssh_proxy_cmd)

    def test_all_kwargs(self):
        proxy_settings = ProxySettings(
            **{'host': 'foo', 'port': 1234, 'https_host': 'bar',
               'https_port': 2345, 'ssh_proxy_cmd': 'proxy command'})
        self.assertEqual('foo', proxy_settings.host)
        self.assertEqual('1234', proxy_settings.port)
        self.assertEqual('bar', proxy_settings.https_host)
        self.assertEqual('2345', proxy_settings.https_port)
        self.assertEqual('proxy command', proxy_settings.ssh_proxy_cmd)
