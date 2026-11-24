# Phase 0 — feasibility probes (Raspberry Pi 400, Debian 13 trixie, kernel 6.18 rpt, arm64)

Measured on the target device with `v4l2-ctl` / python ioctl (no compilation):

| Probe | Result |
|---|---|
| Encoder node | `/dev/video11`, driver `bcm2835-codec`, card `bcm2835-codec-encode` |
| Output formats (raw in) | YU12, YV12, **NV12**, NV21, RGBP, RGB3, BGR3 |
| Capture formats (out) | **H264**, MJPG (no HEVC / AV1 encode on BCM2711) |
| Size range | 32x32 .. 1920x1920, step 2 |
| 720p H.264 throughput (file fed, High profile) | ~127 fps |
| 1080p H.264 throughput (file fed, High, level 4.0) | ~68 fps, no thermal throttling (42 C) |
| `REQBUFS` caps, OUTPUT & CAPTURE queues | `MMAP`, **`DMABUF`**, `ORPHANED_BUFS` → zero-copy import possible |
| Rate control | **`video_bitrate_mode=CBR` makes STREAMON fail (-ESRCH, "Failed enabling i/p port, ret -3")**; VBR + `video_bitrate` works |
| Working controls | `video_bitrate`, `video_gop_size`, `repeat_sequence_header`, `h264_*_qp_value`, `h264_level`, `h264_profile`, `force_key_frame` |
| dma-heap | `/dev/dma_heap/{system,linux,cma,vidbuf_cached}` (group `video`) |
| CMA | 512 MiB pool, but mostly consumed by desktop (compositor/browsers) — free CMA fluctuates 1–27 MB |
| Display server | labwc (wlroots) → wlr-screencopy / KMS capture usable |

## Design consequences
1. Encoder buffers come from CMA (`videobuf2_dma_contig`). Plan for a small, fixed buffer count and raise CMA if needed (`dtoverlay=vc4-kms-v3d,cma-<N>`).
2. Use **VBR with target bitrate** and drive quality via bitrate + QP bounds; do not use CBR.
3. IDR on demand = `V4L2_CID_MPEG_VIDEO_FORCE_KEY_FRAME`.
4. Zero-copy path: GPU (V3D/GLES) RGB→NV12 into a CMA dma-buf, import via `V4L2_MEMORY_DMABUF` on the OUTPUT queue.
5. Max realistic target: 1080p60 (encoder alone does ~68 fps at 1080p); H.264 only.
