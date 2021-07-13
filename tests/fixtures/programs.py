import pytest
import os
import subprocess
import sys
from collections import namedtuple
from pathlib import Path
import shutil


@pytest.fixture()
def detect_network(tmpdir, *args):
    testbin = tmpdir.mkdir("bin")

    def run(*args, env={}, nodename=None):
        testenv = {"PATH": "{}:/usr/bin:/bin:/usr/sbin:/sbin".format(testbin)}
        testenv.update(env)

        if nodename:
            nodename_path = os.path.join(testbin, "ngcp-nodename")
            with open(nodename_path, "w") as fd:
                fd.write('#!/bin/sh\necho "{}"\n'.format(nodename))
            os.chmod(nodename_path, 755)

        cmd = ["./bin/detect_network.py", "--verbose"] + list(args)
        p = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=testenv
        )
        stdout, stderr = p.communicate(timeout=30)
        stdout, stderr = str(stdout), str(stderr)
        result = namedtuple(
            "ProcessResult", ["returncode", "stdout", "stderr"]
        )(p.returncode, stdout, stderr)
        return result

    return run


@pytest.fixture()
def detect_network_pro(detect_network, tmpdir, *args):
    def run(
        *args,
        config="tests/fixtures/kct_config.yml",
        network="tests/fixtures/pro_network.yml",
    ):
        orig_config = Path(config)
        _config = tmpdir.mkdir("out").join("config.yml")
        shutil.copy(orig_config, _config)
        la = [str(_config), str(network)] + list(args)
        res = detect_network(*la, nodename="sp1")
        flds = ["config", "network", "returncode", "stdout", "stderr"]
        result = namedtuple("Result", flds)(
            _config, network, res.returncode, res.stdout, res.stderr
        )
        return result

    return run


@pytest.fixture()
def detect_network_ce(detect_network, tmpdir, *args):
    def run(
        *args,
        config="tests/fixtures/kct_config.yml",
        network="tests/fixtures/ce_network.yml",
    ):
        orig_config = Path(config)
        _config = tmpdir.mkdir("out").join("config.yml")
        shutil.copy(orig_config, _config)
        la = [str(_config), str(network)] + list(args)
        res = detect_network(*la, nodename="spce")
        flds = ["config", "network", "returncode", "stdout", "stderr"]
        result = namedtuple("Result", flds)(
            _config, network, res.returncode, res.stdout, res.stderr
        )
        return result

    return run


@pytest.fixture()
def generate_test_tt2(*args):
    def run(*args):
        cmd = ["./bin/generate_test_tt2.py"] + list(args)
        p = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
        )
        stdout, stderr = p.communicate(timeout=30)
        stdout, stderr = str(stdout), str(stderr)
        result = namedtuple(
            "ProcessResult", ["returncode", "stdout", "stderr"]
        )(p.returncode, stdout, stderr)
        return result

    return run


@pytest.fixture()
def generate_test_tt2_file(tmpdir, *args):
    fout = tmpdir.join("sip_messages00_test.yml.tt2")
    ferr = tmpdir.join("stderr.txt")

    def run(*args):
        cmd = ["./bin/generate_test_tt2.py"] + list(args)
        with open(fout, "wb") as fo, open(ferr, "wb") as fe:
            with subprocess.Popen(
                cmd, stdout=fo, stderr=fe, encoding="utf-8"
            ) as p:
                p.wait(timeout=30)
                print("done")
        result = namedtuple(
            "ProcessResult", ["returncode", "out_file", "err_file"]
        )(p.returncode, fout, ferr)

        # debug, only printed in logs in case of error
        # print("stdout[{}]:".format(fout))
        # with open(fout, "r") as file:
        #     sys.stdout.writelines(file.readlines())
        sys.stderr.write("stderr[{}]:\n".format(ferr))
        with open(ferr, "r") as file:
            sys.stderr.writelines(file.readlines())
        return result

    return run
