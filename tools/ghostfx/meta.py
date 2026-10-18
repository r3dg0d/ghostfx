"""Shader metadata: parsing the `// @key value` header of shader sources.

The header is the single source of truth for a shader. manifest.json, the
gallery and the CLI are all generated from it.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from .paths import data_root

CATEGORIES: dict[str, str] = {
    "ocean": "Ocean & Water",
    "fire": "Fire & Plasma",
    "particles": "Particles",
    "minecraft": "Minecraft-Inspired",
    "crt": "CRT & Retro Displays",
    "glitch": "Glitch & Corruption",
    "alien": "Alien & Sci-Fi",
    "space": "Space & Cosmos",
    "glass": "Glass & Glossy",
    "electric": "Electricity & Energy",
    "metallic": "Metallic & Industrial",
    "cyberpunk": "Cyberpunk",
    "matrix": "Matrix & Code",
    "nature": "Nature & Atmosphere",
    "liquid": "Liquid Art",
    "geometric": "Geometric Art",
    "portals": "Experimental Portals",
    "experimental": "Experimental",
}

MODES = {"background", "overlay", "glow", "post", "distort"}

# Parameters every shader accepts. (type, default, min, max, description)
COMMON_PARAMS: dict[str, tuple[str, float, float, float, str]] = {
    "INTENSITY": ("float", 0.6, 0.0, 1.0, "Effect strength / how much it replaces the background"),
    "SPEED": ("float", 1.0, 0.0, 4.0, "Animation speed multiplier"),
    "BRIGHTNESS": ("float", 1.0, 0.0, 2.0, "Effect brightness"),
    "SATURATION": ("float", 1.0, 0.0, 2.0, "Effect saturation"),
    "OPACITY": ("float", 1.0, 0.0, 1.0, "Effect opacity over transparent terminal backgrounds"),
    "READABILITY": ("float", 0.7, 0.0, 1.0, "Text protection: luminance cap and halo behind glyphs"),
    "REDUCED_MOTION": ("bool", 0, 0, 1, "Slow all motion to 20%"),
    "REDUCED_FLASH": ("bool", 0, 0, 1, "Attenuate flashes and strobing to 20%"),
    "DISTORT_TEXT": ("bool", 1, 0, 1, "Allow the effect to displace terminal text"),
    "QUALITY": ("int", 1, 0, 2, "0 = eco, 1 = balanced, 2 = ultra"),
    "COLORSPACE": ("int", 0, 0, 2, "0 = auto-detect, 1 = native (alpha-blending=native), 2 = linear"),
    "COLORSPACE_FALLBACK": ("int", 2, 1, 2, "Colour space assumed when auto-detection is ambiguous"),
}

COMMON_COLORS = ("PRIMARY", "SECONDARY", "ACCENT", "BACKGROUND", "FOREGROUND")
DEFAULT_COLORS = {
    "PRIMARY": "#8B5CF6",
    "SECONDARY": "#4C1D95",
    "ACCENT": "#C084FC",
    "BACKGROUND": "#0B0A10",
    "FOREGROUND": "#E6E3F0",
}

STANDARD_PRESETS: dict[str, dict[str, float]] = {
    "subtle": {"INTENSITY": 0.35, "SPEED": 0.6, "READABILITY": 1.0, "DISTORT_TEXT": 0},
    "balanced": {},
    "cinematic": {"INTENSITY": 1.0, "READABILITY": 0.25, "QUALITY": 2},
}

PROFILES = {"eco": 0, "balanced": 1, "ultra": 2}

_ID_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
_HEX_RE = re.compile(r"^#[0-9a-fA-F]{6}$")
_HEADER_RE = re.compile(r"^//\s*@([a-z_]+)\s*(.*?)\s*$")


class MetaError(ValueError):
    pass


@dataclass
class Param:
    name: str
    type: str
    default: float
    min: float
    max: float
    description: str

    def to_json(self) -> dict:
        return {
            "name": self.name,
            "type": self.type,
            "default": self.default,
            "min": self.min,
            "max": self.max,
            "description": self.description,
        }


@dataclass
class Shader:
    id: str
    name: str
    category: str
    description: str
    path: Path
    mode: str = "background"
    tags: list[str] = field(default_factory=list)
    uses: list[str] = field(default_factory=list)
    colors: dict[str, str] = field(default_factory=dict)
    params: dict[str, Param] = field(default_factory=dict)
    preset_overrides: dict[str, dict[str, float]] = field(default_factory=dict)
    limitations: list[str] = field(default_factory=list)
    inspired_by: str = ""
    animated: bool = True
    flashing: bool = False
    distorts_text: bool = False
    author: str = "GhostFX Contributors"
    license: str = "MIT"
    version: str = "1.0.0"
    body: str = ""

    @property
    def presets(self) -> list[str]:
        return list(dict.fromkeys([*STANDARD_PRESETS, *self.preset_overrides]))

    def preset_values(self, preset: str) -> dict[str, float]:
        if preset not in STANDARD_PRESETS and preset not in self.preset_overrides:
            raise MetaError(f"{self.id}: unknown preset '{preset}'")
        vals = dict(STANDARD_PRESETS.get(preset, {}))
        vals.update(self.preset_overrides.get(preset, {}))
        return vals

    def all_colors(self) -> dict[str, str]:
        c = dict(DEFAULT_COLORS)
        c.update(self.colors)
        return c

    def rel_source(self) -> str:
        try:
            return self.path.relative_to(data_root()).as_posix()
        except ValueError:
            return self.path.as_posix()


def _num(s: str) -> float:
    v = float(s)
    return int(v) if v.is_integer() and "." not in s else v


def _parse_assign(tokens: list[str], where: str) -> dict[str, float]:
    out: dict[str, float] = {}
    for tok in tokens:
        if "=" not in tok:
            raise MetaError(f"{where}: expected KEY=VALUE, got '{tok}'")
        k, v = tok.split("=", 1)
        out[k.strip().upper()] = _num(v.strip())
    return out


def parse_shader(path: Path) -> Shader:
    text = path.read_text(encoding="utf-8")
    fields: dict[str, str] = {}
    colors: dict[str, str] = {}
    params: dict[str, Param] = {}
    presets: dict[str, dict[str, float]] = {}
    limitations: list[str] = []
    body_lines: list[str] = []
    in_header = True
    where = path.name

    for line in text.splitlines():
        m = _HEADER_RE.match(line) if in_header else None
        if m:
            key, val = m.group(1), m.group(2)
            if key == "color":
                name, hexv = val.split()[:2]
                if not _HEX_RE.match(hexv):
                    raise MetaError(f"{where}: bad color '{hexv}'")
                colors[name.upper()] = hexv.upper()
            elif key == "param":
                parts = val.split(None, 5)
                if len(parts) < 6:
                    raise MetaError(f"{where}: @param needs NAME TYPE DEFAULT MIN MAX DESCRIPTION")
                name, typ, d, lo, hi, desc = parts
                if typ not in ("float", "int", "bool"):
                    raise MetaError(f"{where}: param {name} has bad type {typ}")
                params[name.upper()] = Param(name.upper(), typ, _num(d), _num(lo), _num(hi), desc)
            elif key == "preset":
                parts = val.split()
                presets.setdefault(parts[0], {}).update(_parse_assign(parts[1:], where))
            elif key == "limitation":
                limitations.append(val)
            else:
                if key in fields and key not in ("description",):
                    raise MetaError(f"{where}: duplicate @{key}")
                fields[key] = (fields[key] + " " + val) if key in fields else val
            continue
        if in_header and line.strip() == "":
            continue
        if in_header and line.startswith("//") and not _HEADER_RE.match(line):
            # free-form comment in header area: keep in body
            pass
        in_header = False
        body_lines.append(line)

    for req in ("id", "name", "category", "description"):
        if req not in fields:
            raise MetaError(f"{where}: missing @{req}")

    sid = fields["id"]
    if not _ID_RE.match(sid):
        raise MetaError(f"{where}: invalid id '{sid}'")
    if path.stem != sid:
        raise MetaError(f"{where}: file name must match @id '{sid}'")
    cat = fields["category"]
    if cat not in CATEGORIES:
        raise MetaError(f"{where}: unknown category '{cat}'")
    mode = fields.get("mode", "background")
    if mode not in MODES:
        raise MetaError(f"{where}: unknown mode '{mode}'")

    def flag(name: str, default: bool) -> bool:
        v = fields.get(name)
        return default if v is None else v.lower() in ("1", "true", "yes")

    for pname in params:
        if pname in COMMON_PARAMS or pname in COMMON_COLORS:
            raise MetaError(f"{where}: param {pname} shadows a common parameter")

    return Shader(
        id=sid,
        name=fields["name"],
        category=cat,
        description=fields["description"],
        path=path,
        mode=mode,
        tags=[t.strip() for t in fields.get("tags", "").split(",") if t.strip()],
        uses=fields.get("uses", "").split(),
        colors=colors,
        params=params,
        preset_overrides=presets,
        limitations=limitations,
        inspired_by=fields.get("inspired", ""),
        animated=flag("animated", True),
        flashing=flag("flashing", False),
        distorts_text=flag("distorts", False),
        author=fields.get("author", "GhostFX Contributors"),
        license=fields.get("license", "MIT"),
        version=fields.get("version", "1.0.0"),
        body="\n".join(body_lines).strip() + "\n",
    )


def load_all(root: Path | None = None) -> list[Shader]:
    root = root or data_root()
    shaders = [parse_shader(p) for p in sorted((root / "shaders").glob("*/*.glsl"))]
    seen: dict[str, Path] = {}
    for s in shaders:
        if s.id in seen:
            raise MetaError(f"duplicate shader id {s.id}: {seen[s.id]} and {s.path}")
        if s.path.parent.name != s.category:
            raise MetaError(f"{s.path}: lives in '{s.path.parent.name}' but @category is '{s.category}'")
        seen[s.id] = s.path
    return shaders


def find(shader_id: str, root: Path | None = None) -> Shader:
    root = root or data_root()
    for p in (root / "shaders").glob(f"*/{shader_id}.glsl"):
        return parse_shader(p)
    raise MetaError(f"unknown shader '{shader_id}'")
