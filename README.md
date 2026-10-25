# 🚀 Quake 3 Arena — OSP server in Docker

![OSP](https://img.shields.io/badge/OSP-1.03a-e05d44) ![engine](https://img.shields.io/badge/engine-ioquake3%201.36-2ea44f) ![registry](https://img.shields.io/badge/registry-Forgejo%C2%A0%C2%B7%C2%A0Docker%20Hub-0b7285)

Stand up a **Quake 3 Arena** dedicated server with the full **OSP 1.03a** mod in one command — built for LAN parties. Your crew's instagib config boots by default; the only thing you supply is your own `pak0.pk3`.

## 📦 What's in the image

- **OSP 1.03a** — the full mod
- **ioquake3 1.36** dedicated server from Debian stable — security updates via apt
- **`lanwarig.cfg` by default** — instagib arena on q3dm17, or swap in any of OSP's mode configs
- **Hardened runtime** — unprivileged `q3server` user, healthcheck baked in, game data checksum-pinned at build

## 📋 Requirements

One file: your own `pak0.pk3` (i.e. you own the game).

| Where it lives | Path |
| --- | --- |
| Steam, Linux | `~/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3` |
| Steam, Windows | `C:\Program Files (x86)\Steam\steamapps\common\Quake 3 Arena\baseq3\pak0.pk3` |
| CD install | `quake3/baseq3/pak0.pk3` |

`docker` or `podman` — the commands below use `docker`; for `podman`, just swap the name. The image lives canonically in this repo's [Forgejo registry](https://git.michalkozak.cz/wokoman/docker-quake3-osp-server) and is mirrored to Docker Hub as `wokoman/quake3-osp-server`. Both pull anonymously; a login is only needed to push.

## 🏁 Quickstart

**1 · Pull** the image — both registries serve anonymous pulls:

```shell
docker pull git.michalkozak.cz/wokoman/quake3-osp-server
# fallback mirror: docker pull wokoman/quake3-osp-server
```

**2 · Run** the server, pointing the mount at your `pak0.pk3`:

```shell
docker run --name q3aospserver -d --restart=always -p 27960:27960/udp \
-v "$HOME/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3:/usr/share/games/quake3/baseq3/pak0.pk3:ro" \
git.michalkozak.cz/wokoman/quake3-osp-server
```

**3 · Play** — players join from the Q3 console: `connect <your LAN IP>`.

> **SELinux hosts** (Fedora/RHEL family): use `:ro,Z` in the mount instead of `:ro`, otherwise the engine cannot read `pak0.pk3`.

Want it walked step by step? [`scripts/host-wizard.sh`](scripts/host-wizard.sh) runs the same flow interactively, probing your OS for the `pak0.pk3` path, firewall rules and autostart wiring.

### Start at boot

`--restart=always` brings the server back whenever the engine runs — the engine itself must autostart too:

- **Docker Desktop** (Windows/macOS): enable *Start Docker Desktop when you sign in*
- **rootless podman**: `systemctl --user enable --now podman-restart.service`, plus `loginctl enable-linger` to serve before anyone logs in
- **system docker** (Linux): nothing to do

If players can't see the server, allow inbound **UDP 27960** in your host firewall.

## 🎮 Modes & custom config

Any of OSP's own mode configs can replace the default — append `+exec`, e.g. freezetag:

```shell
docker run --name q3aospserver -d --restart=always -p 27960:27960/udp \
-v "$HOME/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3:/usr/share/games/quake3/baseq3/pak0.pk3:ro" \
git.michalkozak.cz/wokoman/quake3-osp-server +exec freezetag.cfg
```

| Config | Mode |
| --- | --- |
| `lanwarig.cfg` | Instagib arena — the default, your crew's party config |
| `instagib.cfg` | Instagib |
| `ffa.cfg` | Free for all |
| `ctf.cfg` | Capture the flag |
| `1v1.cfg` | Duel |
| `team.cfg` | Team deathmatch |
| `clanarena.cfg` | Clan arena |
| `freezetag.cfg` | Freeze tag |
| `lanwarctf.cfg` | Capture the flag, LAN party flavor |

Bring your own server config — mount it and exec it:

```shell
docker run --name q3aospserver -d --restart=always -p 27960:27960/udp \
-v "$HOME/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3:/usr/share/games/quake3/baseq3/pak0.pk3:ro" \
-v /path/to/server.cfg:/usr/share/games/quake3/osp/server.cfg \
git.michalkozak.cz/wokoman/quake3-osp-server +exec server.cfg
```

There's also a [`docker-compose.yml.example`](docker-compose.yml.example) you can freely customize.

## ⚙️ Defaults & administration

The default config (`lanwarig.cfg`) starts instagib arena on q3dm17 with fraglimit 30.

> ⚠️ **The default rcon password is `kolikchcesparku` and it is published right here.** Change it before exposing the server to the internet — put `seta rconpassword "<secret>"` in your `server.cfg`, or run `rcon seta rconpassword "<secret>"` in-game.

## 🔧 Maintainer notes — build & release

Before releasing, run the smoke test — it builds the image, boots it against a real `pak0.pk3` and asserts over the game's UDP status query that OSP is served with the default config active. It defaults to the Steam install location; pass a path to use another `pak0.pk3`:

```shell
./smoke_test.py
```

Publish to the Forgejo registry (canonical), keeping `latest` plus a `yymmdd` build date:

```shell
docker login git.michalkozak.cz
docker build -t git.michalkozak.cz/wokoman/quake3-osp-server:latest .
docker tag git.michalkozak.cz/wokoman/quake3-osp-server:latest git.michalkozak.cz/wokoman/quake3-osp-server:$(date +%y%m%d)
docker push git.michalkozak.cz/wokoman/quake3-osp-server:latest
docker push git.michalkozak.cz/wokoman/quake3-osp-server:$(date +%y%m%d)
```

Then mirror the same image to Docker Hub:

```shell
docker tag git.michalkozak.cz/wokoman/quake3-osp-server:latest wokoman/quake3-osp-server:latest
docker tag git.michalkozak.cz/wokoman/quake3-osp-server:latest wokoman/quake3-osp-server:$(date +%y%m%d)
docker push wokoman/quake3-osp-server:latest
docker push wokoman/quake3-osp-server:$(date +%y%m%d)
```

> **podman users:** podman's default OCI image build drops `HEALTHCHECK` metadata; build with `--format docker` to keep it. Images built and released with docker carry it.

## 🩺 Troubleshooting

Start with the logs: `docker logs q3aospserver`

| Symptom | Cause | Fix |
| --- | --- | --- |
| Client hangs forever at "connecting", no error | `connect localhost` resolves to IPv6 `::1`, which rootless runtimes don't forward — packets vanish silently | `connect 127.0.0.1` or the host's LAN IP |
| Engine can't read `pak0.pk3` | SELinux on Fedora/RHEL | mount with `:ro,Z` instead of `:ro` |
| Players don't see the server | host firewall | allow inbound UDP 27960 |

## 💚 Shoutouts

Forked from [InAmiTe's docker-quake3](https://github.com/InAnimaTe/docker-quake3), who built on [jberrenberg's image](https://hub.docker.com/r/jberrenberg/quake3) in the first place — shoutout!

Thanks also to the Debian Games Team for [the excellent `quake3-server` package](https://packages.debian.org/stable/games/quake3-server).

## 📚 How-tos

Helpful links for `server.cfg` and rcon, the old-school way — several are preserved archives of classic guides:

- [JoZ3D's console command reference](http://www.joz3d.net/html/q3console.html) — every console command there is
- [TLDP Game Server HOWTO](http://www.tldp.org/HOWTO/archived/Game-Server-HOWTO/quake3.html) — server basics (archived)
- [KatsBits: adding and removing bots](https://www.katsbits.com/site/add-remove-bots/)
- [Arqade: private server with bots](https://gaming.stackexchange.com/questions/46735/quake-3-private-server-with-bots)
- [3D Gaming's server setup guide](https://web.archive.org/web/20230201102926/http://www.3dgw.com/guides/q3a/index.php3?page=configs.htm) (Wayback snapshot)
