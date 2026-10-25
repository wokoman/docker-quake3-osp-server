# Glossary

- **OSP** (Orange Smoothie Productions) — the Quake 3 mod this server runs (`fs_game osp`), version 1.03a, supplied as `osp103a.tar.gz`.
- **ioq3ded** — the ioquake3 dedicated server binary; the container's entrypoint.
- **Point release 1.32b** — id Software's final Q3A patch; its data files (`pak1.pk3`–`pak8.pk3`) are extracted from `linuxq3apoint-1.32b-3.x86.run` into `baseq3/`.
- **pak0.pk3** — retail game data, not redistributable; user-supplied at runtime (e.g. from a Steam install).
- **lanwarig.cfg** — the OSP config the default `CMD` executes: fraglimit 30 on q3dm17, instagib on.
- **getstatus** — the UDP status query every Q3 server answers with hostname, map, and mod; the smoke test's probe.
