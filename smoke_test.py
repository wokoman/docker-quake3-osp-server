#!/usr/bin/env python3
"""Smoke test: build the image, boot it with a real pak0.pk3, assert it serves OSP
with the default lanwarig.cfg config.

Usage: ./smoke_test.py [path/to/pak0.pk3]
"""
import shutil
import socket
import subprocess
import sys
import time
from pathlib import Path

IMAGE = "q3-osp-smoke:test"
CONTAINER = "q3-osp-smoke"
PAK0 = Path.home() / ".local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3"
QUERY = b"\xff\xff\xff\xffgetstatus\n"
PAK0_MOUNT_PATH = "/usr/share/games/quake3/baseq3/pak0.pk3"


def getstatus() -> str:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.settimeout(2)
        s.sendto(QUERY, ("127.0.0.1", 27960))
        data, _ = s.recvfrom(4096)
    return data.decode("latin-1")


def main() -> None:
    pak0 = Path(sys.argv[1]) if len(sys.argv) > 1 else PAK0
    if not pak0.is_file():
        sys.exit(f"pak0.pk3 not found: {pak0}")
    runtime = shutil.which("docker") or shutil.which("podman")
    if runtime is None:
        sys.exit("neither docker nor podman found")

    subprocess.run([runtime, "build", "-t", IMAGE, "."], check=True)
    subprocess.run([runtime, "rm", "-f", CONTAINER], capture_output=True)
    subprocess.run(
        [runtime, "run", "-d", "--name", CONTAINER,
         "-p", "27960:27960/udp",
         "-v", f"{pak0}:{PAK0_MOUNT_PATH}:ro,Z",
         IMAGE],
        check=True,
    )
    try:
        reply = None
        for _ in range(30):
            time.sleep(1)
            try:
                reply = getstatus()
                break
            except (socket.timeout, ConnectionRefusedError):
                continue
        if reply is None:
            sys.exit("server never answered getstatus")
        assert "statusResponse" in reply, f"unexpected reply: {reply!r}"
        assert "mapname" in reply, f"no map loaded: {reply!r}"
        assert "\\gamename\\osp" in reply, f"OSP mod not reported: {reply!r}"
        assert "\\sv_hostname\\Lenver InstagibF" in reply, f"default config lanwarig.cfg not active: {reply!r}"
        subprocess.run([runtime, "exec", CONTAINER, "/usr/local/bin/healthcheck.sh"], check=True)
        print(f"smoke OK: server answers getstatus with OSP ({reply.splitlines()[1][:120]}...)")
    except (SystemExit, AssertionError, subprocess.CalledProcessError):
        logs = subprocess.run([runtime, "logs", CONTAINER],
                              capture_output=True, text=True)
        print(logs.stdout, logs.stderr, file=sys.stderr)
        raise
    finally:
        subprocess.run([runtime, "rm", "-f", CONTAINER], capture_output=True)


if __name__ == "__main__":
    main()
