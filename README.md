# sunshine_rpi_400
Upstream **LizardByte/Sunshine** (pinned stable tag) + our own **V4L2 M2M hardware H.264 encoder backend** for Raspberry Pi 4/400 (BCM2711).

* CI builds natively on GitHub's free arm64 runner inside `debian:trixie` and publishes a `.deb`.
* Our code is kept as an ordered patch series in `patches/` (rebases cleanly on new upstream tags).
* Findings so far: see `docs/PHASE0.md`.

Status: Phase 0 done (hardware verified) → Phase 1 baseline CI build running.
