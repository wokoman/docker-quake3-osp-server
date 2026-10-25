# 🚀 QUAKE 3 ARENA OSP IN DOCKER

Running this image starts **Quake 3 Arena** server with OSP and instagib on. Using full **OSP 1.03a**.

### Requirements
This image is fully functional, you only need to supply your own `pak0.pk3` file. If you own the game on Steam, it lives in `steamapps/common/Quake 3 Arena/baseq3/pak0.pk3`. If yours lives elsewhere (e.g. a CD install), adjust the mount path below.

```shell
docker run --name q3aospserver -d -p 27960:27960/udp \
-v "$HOME/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3:/usr/share/games/quake3/baseq3/pak0.pk3" \
wokoman/quake3-osp-server
```

### Customization
To run one of OSP's own mode configs instead of the default instagib, append `+exec`, e.g. freezetag:

```shell
docker run --name q3aospserver -d -p 27960:27960/udp \
-v "$HOME/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3:/usr/share/games/quake3/baseq3/pak0.pk3" \
wokoman/quake3-osp-server +exec freezetag.cfg
```

Other included modes: `ffa.cfg`, `ctf.cfg`, `1v1.cfg`, `team.cfg`, `clanarena.cfg`, `instagib.cfg`, `lanwarig.cfg`, `lanwarctf.cfg`.

Or bring your own server config — mount it and exec it:

```shell
docker run --name q3aospserver -d -p 27960:27960/udp \
-v "$HOME/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3:/usr/share/games/quake3/baseq3/pak0.pk3" \
-v /path/to/server.cfg:/usr/share/games/quake3/osp/server.cfg \
wokoman/quake3-osp-server +exec server.cfg
```

There's also an example `docker-compose.yml` in the repo which you can freely customize.

### Defaults
The default config (`lanwarig.cfg`) starts arena with fraglimit 30 on q3dm17 with instagib on.

⚠️ **The default rcon password is `kolikchcesparku` and it is published right here — change it before exposing the server to the internet.** Set your own in your `server.cfg`, or within game with `;rcon seta rconpassword "<secretpassword>"`.

### Building and releasing
Build and publish with your own tag, keeping `latest` plus a `yymmdd` build date:

```shell
docker build -t wokoman/quake3-osp-server:latest .
docker tag wokoman/quake3-osp-server:latest wokoman/quake3-osp-server:$(date +%y%m%d)
docker push wokoman/quake3-osp-server:latest
docker push wokoman/quake3-osp-server:$(date +%y%m%d)
```

Before releasing, run the smoke test — it builds the image, boots it against a real `pak0.pk3` and asserts over the game's UDP status query that OSP is served. It defaults to the Steam install location; pass a path to use another `pak0.pk3`:

```shell
./smoke_test.py
```

Note for podman users: podman's default OCI image build drops `HEALTHCHECK` metadata; build with `--format docker` to keep it. Images built and released with docker carry it.

### Troubleshooting
The server logs, so you can simply:

```shell
docker logs q3aospserver
```

### Shoutouts
I forked this image from [InAmiTe](https://github.com/InAnimaTe/docker-quake3) who took [jberrenberg](https://hub.docker.com/r/jberrenberg/quake3) image in the first place. Shoutout!

I also wanted to thank the Debian Games Team for [this](https://packages.debian.org/stable/games/quake3-server) excellent package.

### Quake 3 Arena server how-tos

Here are some really helpful links for setting up the `server.cfg` and utilizing rcon. 

* [http://www.joz3d.net/html/q3console.html](http://www.joz3d.net/html/q3console.html)
* [http://it.rcmd.org/networks/q3_install/q3_linux_server_howto.php#step9](http://it.rcmd.org/networks/q3_install/q3_linux_server_howto.php#step9)
* [http://www.tldp.org/HOWTO/archived/Game-Server-HOWTO/quake3.html](http://www.tldp.org/HOWTO/archived/Game-Server-HOWTO/quake3.html)
* [http://gaming.stackexchange.com/questions/46735/quake-3-private-server-with-bots](http://gaming.stackexchange.com/questions/46735/quake-3-private-server-with-bots)
* [http://notes.splitbrain.org/q3aserver](http://notes.splitbrain.org/q3aserver)
* [http://www.katsbits.com/articles/quake-3/add-remove-bots.php](http://www.katsbits.com/articles/quake-3/add-remove-bots.php)
* [http://www.3dgw.com/guides/q3a/index.php3?page=configs.htm#serverbots](http://www.3dgw.com/guides/q3a/index.php3?page=configs.htm#serverbots)
