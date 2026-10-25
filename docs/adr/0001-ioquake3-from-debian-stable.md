# 0001. ioquake3 dedicated server from Debian stable

Status: accepted

## Context

The image was built on `debian:jessie`, whose archives are gone, so the build no longer runs at all. The engine came from jessie's `quake3-server` package. Candidates: current distro package, ioquake3.org prebuilt binaries (as the abandoned `upgrade-debian` branch tried), building from source, a third-party base image, or `archive.debian.org` jessie.

## Decision

Base on `debian:stable-slim` and install the distro's `ioquake3-server` package (present in trixie), which ships the `ioq3ded` dedicated binary. Engine updates ride Debian security support.

## Consequences

Entrypoint and paths change from the jessie layout; the healthcheck must match the actual binary name. The prebuilt-binary route is rejected: it mixes engine sources with the distro package, gets no security updates, and depends on `files.ioquake3.org` staying up. Engine version is whatever Debian stable ships — explicit engine pinning would require building from source.
