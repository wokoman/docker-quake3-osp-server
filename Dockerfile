FROM debian:stable-slim AS game-data

# Checksums pin the frozen artifacts against silent upstream change (ADR-0002);
# GWDG mirrors the long-dead id FTP, the Azure blob is OSP's source of record.
WORKDIR /data
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates wget \
 && (wget -nv -O point-release.run https://ftp.gwdg.de/pub/misc/ftp.idsoftware.com/idstuff/quake3/linux/linuxq3apoint-1.32b-3.x86.run \
  || wget -nv -O point-release.run https://dockerq3aosp.blob.core.windows.net/dockerq3aosp/linuxq3apoint-1.32b-3.x86.run) \
 && echo "c36132c5556b35e01950f1e9c646235033a5130f87ad776ba2bc7becf4f4f186  point-release.run" | sha256sum -c - \
 && chmod +x point-release.run \
 && ./point-release.run --tar xvf baseq3 \
 && wget -nv -O osp103a.tar.gz https://dockerq3aosp.blob.core.windows.net/dockerq3aosp/osp103a.tar.gz \
 && echo "207f2541ff444682cf7920a5373c34fca8266b773fbb4897ba1c3ba7d7ac5914  osp103a.tar.gz" | sha256sum -c - \
 && tar -xzf osp103a.tar.gz

FROM debian:stable-slim

# ioq3ded from the distro (ADR-0001); q3server keeps the engine unprivileged.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ioquake3-server \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --system --create-home --home-dir /var/lib/q3server q3server

COPY --from=game-data /data/baseq3 /usr/share/games/quake3/baseq3
COPY --from=game-data /data/osp /usr/share/games/quake3/osp
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

USER q3server
WORKDIR /usr/share/games/quake3

# fs_basepath keeps the documented pak0.pk3 mount path working (the Debian engine's
# compiled-in basepath is /usr/lib/ioquake3). Base args live in ENTRYPOINT so a
# custom command only replaces the +exec line, as the README examples assume.
ENTRYPOINT ["/usr/lib/ioquake3/ioq3ded", "+set", "dedicated", "1", "+set", "fs_basepath", "/usr/share/games/quake3", "+set", "fs_game", "osp"]
CMD ["+exec", "lanwarig.cfg"]

EXPOSE 27960/udp
HEALTHCHECK --start-period=5s CMD /usr/local/bin/healthcheck.sh
