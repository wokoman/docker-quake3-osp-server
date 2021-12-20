FROM debian:bullseye-slim@sha256:312218c8dae688bae4e9d12926704fa9af6f7307a6edb4f66e479702a9af5a0c

ENV ioquake_data linuxq3apoint-1.32b-3.x86.run
ENV osp osp103a.tar.gz

RUN sed -i -e's/ main/ main contrib/g' /etc/apt/sources.list \
        && apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y --no-install-recommends quake3-server=67 wget=1.21-1+b1 ca-certificates=20210119 gdb \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/locale/* \
        /var/cache/debconf/*-old \
        /usr/share/doc/*

WORKDIR /usr/share/games/quake3

RUN wget -nv "https://dockerq3aosp.blob.core.windows.net/dockerq3aosp/linuxq3apoint-1.32b-3.x86.run" \
        && chmod +x ${ioquake_data} \
        && ./${ioquake_data} --tar xvf \
        && rm -rf ./${ioquake_data} \
        && wget -nv "https://dockerq3aosp.blob.core.windows.net/dockerq3aosp/${osp}" \
        && tar -xvzf ${osp}

## You can include the pak0.pk3 file during the build, if you want to
#COPY pak0.pk3 baseq3/

# USER Debian-quake3

EXPOSE 27960/udp

HEALTHCHECK --start-period=5s CMD ps -C ioq3ded

ENTRYPOINT ["/usr/games/quake3-server"]

CMD ["+set", "dedicated", "1", "+set", "fs_game", "osp", "+exec", "lanwarig.cfg"]
