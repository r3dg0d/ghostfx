# Performance

> **These numbers come from software rendering, not a GPU.** They were measured with Mesa
> `llvmpipe (LLVM 20.1.2, 256 bits)` on a 4-vCPU cloud VM (Intel Xeon @ 2.10 GHz, no GPU), under Xvfb, on 2026-10-19.
> llvmpipe runs the fragment shader on the CPU, so absolute times say nothing about GPU
> frame rates. Use this table only to **rank shaders against each other**. No
> RTX 4090, Apple Silicon or other real-GPU measurements have been recorded yet.

## Method

`benchmarks/run.sh` calls `ghostfx benchmark`. For each shader it:

1. builds the balanced preset and prepends Ghostty 1.3's real shader prefix;
2. compiles it the way Ghostty does (glslang → SPIR-V → SPIRV-Cross GLSL 4.30);
3. draws a full-screen pass with a real Ghostty capture as `iChannel0`;
4. times each frame with `GL_TIME_ELAPSED` queries. The table shows 10 frames after warm-up,
   as median / p95 in milliseconds per frame.

Raw data: [`benchmarks/results.json`](../benchmarks/results.json).

## Results (llvmpipe, ms per frame, median / p95)

| Shader | 1920x1080 | 2560x1440 | 3440x1440 | 3840x2160 |
|---|---:|---:|---:|---:|
| digital-glitch | 42.4 / 42.8 | 79.5 / 85.3 | 101.6 / 107.3 | 157.7 / 163.4 |
| alien-interface | 60.5 / 62.6 | 107.5 / 109.8 | 147.2 / 157.4 | 229.0 / 234.2 |
| matrix-rain | 64.0 / 71.1 | 111.8 / 119.1 | 153.2 / 163.1 | 238.7 / 248.8 |
| hexagonal-grid | 71.3 / 77.9 | 109.2 / 115.7 | 152.9 / 155.6 | 249.4 / 265.3 |
| black-hole | 71.8 / 74.4 | 129.1 / 138.0 | 190.1 / 203.7 | 283.8 / 294.4 |
| starfield | 72.8 / 75.9 | 141.8 / 144.1 | 181.3 / 202.2 | 285.5 / 300.8 |
| classic-crt | 73.1 / 77.4 | 131.8 / 146.6 | 179.3 / 189.2 | 286.7 / 291.9 |
| liquid-gradient | 73.6 / 77.5 | 125.9 / 129.9 | 165.3 / 171.4 | 283.3 / 287.1 |
| liquid-metal | 73.6 / 83.8 | 135.8 / 136.9 | 182.9 / 196.1 | 292.3 / 308.7 |
| liquid-glass | 76.2 / 79.1 | 128.4 / 134.1 | 178.3 / 183.3 | 287.5 / 297.4 |
| northern-lights | 81.4 / 84.6 | 157.5 / 176.8 | 189.4 / 197.7 | 322.9 / 339.8 |
| lightning | 88.3 / 93.7 | 139.4 / 146.5 | 192.5 / 202.6 | 330.4 / 349.5 |
| realistic-fire | 95.2 / 99.2 | 178.1 / 190.8 | 229.1 / 241.1 | 379.9 / 398.6 |
| fog | 101.6 / 106.4 | 171.8 / 175.4 | 238.3 / 253.3 | 407.2 / 442.0 |
| ender-portal | 102.8 / 108.7 | 184.9 / 199.4 | 254.1 / 260.9 | 431.6 / 458.2 |
| nebula | 106.5 / 108.7 | 191.7 / 199.0 | 241.1 / 252.2 | 402.0 / 413.0 |
| underwater-caustics | 107.5 / 112.1 | 177.6 / 179.7 | 246.5 / 249.7 | 403.4 / 407.9 |
| reality-break | 120.9 / 127.1 | 214.0 / 266.2 | 300.2 / 327.2 | 492.7 / 534.7 |
| fractal-zoom | 126.9 / 133.7 | 235.8 / 253.5 | 269.2 / 279.0 | 476.2 / 486.1 |
| ocean-waves | 130.1 / 137.4 | 217.6 / 226.2 | 290.7 / 302.3 | 503.4 / 515.3 |

Cost scales roughly with pixel count. 3840×2160 has 4× the pixels of 1920×1080 and costs about 3.7–4× as much.
The heaviest shaders here (ocean-waves, fractal-zoom, reality-break) cost about 3× the lightest
(digital-glitch). `--quality eco` lowers octave, step and layer counts.

## Practical guidance

* Ghostty only redraws the shader while animating. With `custom-shader-animation = true` (the
  default), that only happens while the window is focused.
* On laptops or iGPUs, use `--quality eco` or the `subtle` preset.
* For a static look (`@animated false`, e.g. classic-crt, amber-terminal), set
  `custom-shader-animation = false`: Ghostty then runs the shader only when it redraws the
  terminal, not every frame.

## Contributing measurements

```sh
benchmarks/run.sh                       # representative set, 4 resolutions
GHOSTFX_BENCH_ALL=1 benchmarks/run.sh   # every shader
```

Open a PR with the resulting `benchmarks/results.json`, plus your GPU, driver and OS. Real GPU
numbers, particularly from an RTX 4090 at 3440×1440 and from Apple Silicon, are the most-wanted
contribution before v1.0.
