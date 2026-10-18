# Third-party notices

GhostFX's shaders are original procedural work. A few small, well-known
building blocks and reference files come from elsewhere:

| What | Where in GhostFX | Source | License |
|---|---|---|---|
| Ghostty's shadertoy prefix (uniform block layout), copied verbatim for validation | `compat/ghostty-1.3-prefix.glsl`, `compat/ghostty-1.2-prefix.glsl` | [ghostty-org/ghostty](https://github.com/ghostty-org/ghostty) `src/renderer/shaders/shadertoy_prefix.glsl` (v1.3.1, v1.2.3) | MIT, © Mitchell Hashimoto, Ghostty contributors |
| "Hash without Sine" hash functions | `glsl/common/hash.glsl` | David Hoskins, [shadertoy.com/view/4djSRW](https://www.shadertoy.com/view/4djSRW) | MIT |
| 2D SDF formulas (box, segment, hexagon, triangle, 5-point star), polynomial smooth-min, cosine palettes, domain-warping technique | `glsl/sdf/sdf.glsl`, `glsl/color/color.glsl`, `glsl/noise/fbm.glsl` | Inigo Quilez, [iquilezles.org/articles](https://iquilezles.org/articles/) | MIT (as stated for the article snippets) |
| RGB→HSV conversion | `glsl/color/color.glsl` (`rgb2hsv`) | Sam Hocevar, lolengine.net | WTFPL |
| Fitted ACES tonemapping curve | `glsl/color/color.glsl` (`tonemap_aces`) | Krzysztof Narkowicz, "ACES Filmic Tone Mapping Curve" (2016) | formula published for free use |
| Simplex noise skew constants | `glsl/noise/simplex.glsl` | Stefan Gustavson, "Simplex noise demystified" | algorithm description (own implementation) |

Minecraft-inspired shaders (`shaders/minecraft/`) are original procedural
interpretations of the game's visual language. They contain no textures, images
or other assets from Minecraft. Minecraft is a trademark of Mojang Synergies AB;
GhostFX is not affiliated with or endorsed by Mojang or Microsoft.

Ghostty is a project by Mitchell Hashimoto and contributors; GhostFX is an
independent community project.
