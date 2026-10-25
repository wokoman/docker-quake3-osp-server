# 0002. Game data sources and checksum pinning

Status: accepted

## Context

The build fetches two artifacts: `linuxq3apoint-1.32b-3.x86.run` (id Software's 1.32b point-release data) and `osp103a.tar.gz` (OSP 1.03a), both from an Azure blob (`dockerq3aosp.blob.core.windows.net`). The blob is alive but is a single point of failure: if it dies, every future build dies. id's original FTP is long gone; searching found no trustworthy public mirror of `osp103a.tar.gz`, but `ftp.gwdg.de` (Göttingen university mirror of `ftp.idsoftware.com`) serves the point release byte-identical to the blob copy.

## Decision

Fetch the point release from the GWDG mirror with the Azure blob as fallback. Fetch `osp103a.tar.gz` from the Azure blob (source of record — no reliable public copy exists). Pin SHA-256 checksums for both in the Dockerfile so any silent change or corruption fails the build.

## Consequences

Builds survive the loss of either host individually. If the blob disappears entirely, the follow-up is a one-time mirror of `osp103a.tar.gz` (and the point release) into this repo's Forgejo release assets — the files are frozen historical artifacts and never change — after which the build depends only on own infra.
