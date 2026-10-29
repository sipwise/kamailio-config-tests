#!/usr/bin/python3
#
# Copyright: 2026 Sipwise Development Team <support@sipwise.com>
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
"""Check the RTP received by the sipp end-points of a scenario.

Only the end-points having a 'rtp_check' in scenario.yml are checked,
see README.
"""
import argparse
import sys
from pathlib import Path

from yaml import load

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

KEYS = ("streams", "min_packets")


def load_yaml(path):
    with open(path, "r") as f:
        return load(f, Loader=Loader)


def get_endpoints(scen_file, ids_file):
    """End-points with a 'rtp_check', along with their media address"""
    scen = load_yaml(scen_file)
    found = []
    res_id = 0
    for i, s in enumerate(scen.get("scenarios", [])):
        if "rtp_check" in s:
            found.append(("sipp_scenario%02d" % i, i, None, s["rtp_check"]))
        for j, r in enumerate(s.get("responders", [])):
            if "rtp_check" in r:
                name = "sipp_scenario_responder%02d" % res_id
                found.append((name, i, j, r["rtp_check"]))
            res_id += 1
    if not found:
        return []

    # ip and media port are only known once the scenario is provided
    ids = load_yaml(ids_file)
    endpoints = []
    for name, i, j, check in found:
        if not isinstance(check, dict) or not any(k in check for k in KEYS):
            raise ValueError(
                "%s: rtp_check needs any of %s" % (name, ", ".join(KEYS))
            )
        net = ids["scenarios"][i]
        if j is not None:
            net = net["responders"][j]
        if net.get("mport") is None:
            raise ValueError("%s: no media port" % name)
        endpoints.append({
            "name": name,
            "ip": net["ip"],
            "port": int(net["mport"]),
            "check": check,
        })
    return endpoints


def bpf_filter(endpoints):
    """tcpdump filter for the RTP towards the end-points"""
    hosts = [
        "(dst host %s and dst port %d)" % (e["ip"], e["port"])
        for e in endpoints
    ]
    return "udp and (%s)" % " or ".join(hosts)


def count_streams(pcap, endpoints):
    """Packets received by each end-point, per RTP stream (SSRC)"""
    from scapy.all import IP, IPv6, UDP, PcapReader

    streams = {(e["ip"], e["port"]): {} for e in endpoints}
    with PcapReader(str(pcap)) as reader:
        for pkt in reader:
            ip = pkt.getlayer(IP) or pkt.getlayer(IPv6)
            if ip is None or UDP not in pkt:
                continue
            key = (ip.dst, pkt[UDP].dport)
            data = bytes(pkt[UDP].payload)
            # RTP version 2 only, skip anything else (STUN, ...)
            if key not in streams or len(data) < 12 or data[0] >> 6 != 2:
                continue
            ssrc = int.from_bytes(data[8:12], "big")
            streams[key][ssrc] = streams[key].get(ssrc, 0) + 1
    return streams


def check(endpoints, pcap):
    """TAP output of the checks, along with the overall result"""
    if not Path(pcap).is_file():
        output = "1..1\nnot ok 1 - ERROR: File %s does not exists\n" % pcap
        return output, False

    streams = count_streams(pcap, endpoints)
    steps = []
    for e in endpoints:
        found = streams[(e["ip"], e["port"])]
        desc = ", ".join(
            "0x%08x: %d packets" % (ssrc, num) for ssrc, num in found.items()
        )
        steps.append((None, "%s [%s:%d] received %d RTP streams [%s]" % (
            e["name"], e["ip"], e["port"], len(found), desc)))
        if "streams" in e["check"]:
            expected = int(e["check"]["streams"])
            steps.append((
                len(found) == expected,
                "%s RTP streams: %d, expected %d"
                % (e["name"], len(found), expected),
            ))
        if "min_packets" in e["check"]:
            expected = int(e["check"]["min_packets"])
            if not found:
                steps.append((
                    False,
                    "%s no RTP stream, expected at least %d packets"
                    % (e["name"], expected),
                ))
            for ssrc, num in found.items():
                steps.append((
                    num >= expected,
                    "%s RTP stream 0x%08x packets: %d, expected at least %d"
                    % (e["name"], ssrc, num, expected),
                ))

    num = sum(1 for result, _ in steps if result is not None)
    output = "1..%d\n" % num
    test = 0
    for result, msg in steps:
        if result is None:
            output += "# %s\n" % msg
            continue
        test += 1
        if result:
            output += "ok %d - %s\n" % (test, msg)
        else:
            output += "not ok %d - ERROR: %s\n" % (test, msg)
    return output, all(result is not False for result, _ in steps)


def main(args):
    endpoints = get_endpoints(args.scenario, args.ids)
    if not endpoints:
        # nothing to check
        return 0
    if args.filter:
        print(bpf_filter(endpoints))
        return 0
    output, result = check(endpoints, args.pcap)
    print(output, end="")
    return 0 if result else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="check the RTP received by the sipp end-points"
    )
    parser.add_argument(
        "--filter",
        action="store_true",
        help="print the tcpdump filter to capture the RTP to check",
    )
    parser.add_argument("scenario", help="scenario.yml")
    parser.add_argument("ids", help="scenario_ids.yml")
    parser.add_argument("pcap", nargs="?", help="captured RTP")
    args = parser.parse_args()
    if not args.filter and args.pcap is None:
        parser.error("pcap is needed")
    sys.exit(main(args))
