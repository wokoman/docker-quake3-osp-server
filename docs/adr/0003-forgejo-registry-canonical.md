# 0003. Forgejo registry is the canonical image source

Status: accepted

## Context

The image has only ever been published to Docker Hub. The Forgejo instance hosting the repo serves an OCI container registry (`/v2/` confirmed live, `has_packages: True`), so the image can live on the same infra as the code. Docker Hub carries five years of `wokoman/quake3-osp-server` pulls and discoverability.

## Decision

Publish canonically to `git.michalkozak.cz/wokoman/quake3-osp-server` and keep Docker Hub (`wokoman/quake3-osp-server`) as a plain mirror of the same image and tags. Docs and the compose example point at the Forgejo registry; the mirror keeps existing pulls working. The image carries the OCI `source` label so the Forgejo package auto-links to this repo.

## Consequences

Own infra is the source of truth for releases; Docker Hub can lag or be dropped later without breaking documented usage. Anonymous pulls from the Forgejo registry depend on the package being public (check visibility after the first push). Release bandwidth serves from the Forgejo host.
