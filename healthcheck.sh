#!/bin/bash
set -euo pipefail
# Liveness = the server answers a getstatus query, not merely that the process exists.
export LC_ALL=C  # the reply carries 0xFF magic bytes; stay byte-wise
exec 3<>/dev/udp/127.0.0.1/27960 || exit 1
printf '\377\377\377\377getstatus\n' >&3
# one datagram-sized read: a partial UDP read discards the rest of the datagram
reply=$(timeout 2 dd bs=65536 count=1 <&3 2>/dev/null)
[[ $reply == *statusResponse* ]]
