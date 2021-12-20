# syntax=docker/dockerfile:1.3-labs
FROM debian:bullseye-slim

ENV ioquake_data linuxq3apoint-1.32b-3.x86.run
ENV osp osp103a.tar.gz

RUN <<EOF
        sed -i -e's/ main/ main contrib/g' /etc/apt/sources.list
        apt-get update
        apt-get upgrade -y
        apt-get install -y --no-install-recommends quake3-server=67 wget=1.21-1+deb11u1 ca-certificates=20210119
        apt-get clean
        rm -rf /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/locale/* \
        /var/cache/debconf/*-old \
        /usr/share/doc/*
EOF

WORKDIR /usr/share/games/quake3

RUN <<EOF
        wget -nv "https://dockerq3aosp.blob.core.windows.net/dockerq3aosp/${ioquake_data}"
        chmod +x ${ioquake_data}
        ./${ioquake_data} --tar xvf
        rm -rf ./${ioquake_data}
        wget -nv "https://dockerq3aosp.blob.core.windows.net/dockerq3aosp/${osp}"
        tar -xvzf ${osp}
        wget -nv "https://files.ioquake3.org/Linux.zip"
        unzip Linux.zip && unzip release-linux-x86_64.zip
EOF

## You can include the pak0.pk3 file during the build, if you want to
#COPY pak0.pk3 baseq3/

USER Debian-quake3

EXPOSE 27960/udp

HEALTHCHECK --start-period=5s CMD ps -C ioq3ded

ENTRYPOINT ["ioq3ded.x86_64"]

CMD ["+set", "dedicated", "1", "+set", "fs_game", "osp", "+exec", "lanwarig.cfg"]
