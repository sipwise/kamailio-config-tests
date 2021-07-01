#!/usr/bin/python3
#
# Copyright: 2013-2020 Sipwise Development Team <support@sipwise.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# On Debian systems, the complete text of the GNU General
# Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
#
import re
from yaml import load

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

DEFAULT_SIP = "10.20.29.2"
DEFAULT_PEER = "172.30.1.2"


def load_yaml(filepath):
    output = None
    with open(filepath, "r") as file:
        output = load(file, Loader=Loader)
    return output


def compare_values(config, lb_ip, ip, peer_ip):
    cfg = load_yaml(config)
    assert cfg["kamailio"]["lb"]["ip"] == lb_ip
    assert cfg["sip"]["ip"] == ip
    assert cfg["peer"]["ip"] == peer_ip


def test_no_params(detect_network):
    res = detect_network()

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    assert res.returncode != 0


def test_same_ip(detect_network_pro):
    res = detect_network_pro(
        "--peer-ip", "192.168.209.202", "--sip-ip", "192.168.209.202"
    )

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    assert res.returncode != 0


def test_detect_lb(detect_network_pro):
    res = detect_network_pro()

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "192.168.209.202", DEFAULT_SIP, DEFAULT_PEER)

    assert res.returncode == 0


def test_detect_lb_params(detect_network_pro):
    res = detect_network_pro("--peer-ip", "127.0.0.5")

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "192.168.209.202", DEFAULT_SIP, "127.0.0.5")

    assert res.returncode == 0


def test_detect_lb_params2(detect_network_pro):
    res = detect_network_pro("--peer-ip", "127.0.0.5", "--sip-ip", "127.0.0.1")

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "192.168.209.202", "127.0.0.1", "127.0.0.5")

    assert res.returncode == 0


def test_detect_lb_params3(detect_network_pro):
    res = detect_network_pro(
        "--peer-ip",
        "127.0.0.5",
        "--sip-ip",
        "127.0.0.1",
        "--lb-ip",
        "127.0.0.4",
    )

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "127.0.0.4", "127.0.0.1", "127.0.0.5")

    assert res.returncode == 0


def test_detect_ce_lb(detect_network_ce):
    res = detect_network_ce()

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "192.168.209.201", DEFAULT_SIP, DEFAULT_PEER)

    assert res.returncode == 0


def test_detect_ce_lb_params(detect_network_ce):
    res = detect_network_ce("--peer-ip", "127.0.0.5")

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "192.168.209.201", DEFAULT_SIP, "127.0.0.5")

    assert res.returncode == 0


def test_detect_ce_lb_params2(detect_network_ce):
    res = detect_network_ce("--peer-ip", "127.0.0.5", "--sip-ip", "127.0.0.2")

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "192.168.209.201", "127.0.0.2", "127.0.0.5")

    assert res.returncode == 0


def test_detect_ce_lb_params3(detect_network_ce):
    res = detect_network_ce(
        "--peer-ip",
        "127.0.0.5",
        "--sip-ip",
        "127.0.0.2",
        "--lb-ip",
        "127.0.0.4",
    )

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "127.0.0.4", "127.0.0.2", "127.0.0.5")

    assert res.returncode == 0


def test_detect_vagrant_lb(detect_network_pro):
    res = detect_network_pro(network="tests/fixtures/pro_vagrant_network.yml")

    # debug, only printed in logs in case of error
    print("stdout:")
    print(res.stdout.replace("\\n", "\n"))
    print("stderr:")
    print(res.stderr.replace("\\n", "\n"))

    compare_values(res.config, "192.168.2.109", DEFAULT_SIP, DEFAULT_PEER)

    assert res.returncode == 0
