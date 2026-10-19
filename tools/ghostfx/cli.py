"""The `ghostfx` command-line interface."""

from __future__ import annotations

import argparse
import difflib
import json
import os
import platform
import random
import re
import shutil
import subprocess
import sys
from pathlib import Path

from . import __version__, build, ghostty, meta, presets, state
from .meta import CATEGORIES, PROFILES, MetaError
from .paths import data_root, ghostfx_home, ghostty_config_path, installed_shader_dir, user_preset_dir

GENERATED_MARK = "// GhostFX — "


class CliError(RuntimeError):
    pass


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def _tty() -> bool:
    return sys.stdout.isatty() and os.environ.get("NO_COLOR") is None


def c(text: str, code: str) -> str:
    return f"\033[{code}m{text}\033[0m" if _tty() else text


def emit(args, data, human) -> None:
    if getattr(args, "json", False):
        print(json.dumps(data, indent=2, default=str))
    else:
        human()


def info_line(msg: str) -> None:
    print(c("•", "35") + " " + msg)


def ok_line(msg: str) -> None:
    print(c("✓", "32") + " " + msg)


def warn_line(msg: str) -> None:
    print(c("!", "33") + " " + msg, file=sys.stderr)


def confirm(question: str, args) -> bool:
    if getattr(args, "yes", False):
        return True
    if not sys.stdin.isatty():
        return False
    ans = input(f"{question} [y/N] ").strip().lower()
    return ans in ("y", "yes")


# ---------------------------------------------------------------------------
# Build options shared by install/apply/preview
# ---------------------------------------------------------------------------

def add_build_opts(p: argparse.ArgumentParser) -> None:
    p.add_argument("--preset", default="balanced", help="subtle | balanced | cinematic | shader-specific | path to a preset .toml")
    p.add_argument("--palette", help="palette name from themes/ (see `ghostfx palettes`)")
    p.add_argument("--quality", choices=list(PROFILES), help="performance profile: eco | balanced | ultra")
    p.add_argument("--set", action="append", default=[], metavar="KEY=VALUE", help="override a parameter, e.g. --set intensity=0.4 --set primary=#ff00aa")
    p.add_argument("--reduced-motion", action="store_true", help="slow all motion to 20%%")
    p.add_argument("--reduced-flash", action="store_true", help="attenuate flashes and strobing")
    p.add_argument("--high-readability", action="store_true", help="maximum text protection, lower intensity")
    p.add_argument("--no-distort", action="store_true", help="never move or warp the terminal text")
    p.add_argument("--legacy", action="store_true", help="build for Ghostty 1.2 (no colour/focus uniforms)")
    p.add_argument("--colorspace", choices=["auto", "native", "linear"], help="override colour-space handling (default: from your alpha-blending setting)")


def _coerce(v: str):
    lv = v.lower()
    if lv in ("true", "yes", "on"):
        return 1
    if lv in ("false", "no", "off"):
        return 0
    if v.startswith("#"):
        return v
    try:
        return float(v) if "." in v else int(v)
    except ValueError:
        return v


def detect_colorspace(cfg_text: str) -> int:
    """1 = native, 2 = linear, from the user's alpha-blending setting."""
    m = None
    for line in cfg_text.splitlines():
        mm = re.match(r"^\s*alpha-blending\s*=\s*(\S+)", line)
        if mm:
            m = mm.group(1)
    if m is None:
        return 1 if platform.system() == "Darwin" else 2
    return 1 if m == "native" else 2


def resolve_build(args, shader_id: str | None = None):
    """Return (shader, preset_name, overrides, palette, legacy)."""
    preset_name = getattr(args, "preset", "balanced") or "balanced"
    overrides: dict = {}
    palette = None
    pf = None
    if preset_name.endswith(".toml") or preset_name in presets.user_presets():
        pf = presets.load_preset_file(Path(preset_name)) if preset_name.endswith(".toml") else presets.user_presets()[preset_name]
        shader_id = shader_id or pf.shader
        if pf.shader != shader_id:
            raise CliError(f"preset '{preset_name}' is for '{pf.shader}', not '{shader_id}'")
        preset_name = pf.base
        overrides.update(pf.overrides)
        if pf.palette:
            palette = presets.load_palette(pf.palette)
    if not shader_id:
        raise CliError("no shader given")
    shader = meta.find(shader_id)
    if getattr(args, "palette", None):
        palette = presets.load_palette(args.palette)
    if getattr(args, "quality", None):
        overrides["QUALITY"] = PROFILES[args.quality]
    if getattr(args, "reduced_motion", False):
        overrides["REDUCED_MOTION"] = 1
    if getattr(args, "reduced_flash", False):
        overrides["REDUCED_FLASH"] = 1
    if getattr(args, "high_readability", False):
        overrides["READABILITY"] = 1.0
        base = build.resolve_values(shader, preset_name)[0]["INTENSITY"][1]
        overrides.setdefault("INTENSITY", round(min(float(base), 0.6) * 0.75, 3))
    if getattr(args, "no_distort", False):
        overrides["DISTORT_TEXT"] = 0
    for kv in getattr(args, "set", []) or []:
        if "=" not in kv:
            raise CliError(f"--set expects KEY=VALUE, got '{kv}'")
        k, v = kv.split("=", 1)
        overrides[k.strip().upper()] = _coerce(v.strip())
    cs = getattr(args, "colorspace", None)
    if cs:
        overrides["COLORSPACE"] = {"auto": 0, "native": 1, "linear": 2}[cs]
    elif "COLORSPACE" not in overrides:
        cfg = ghostty_config_path()
        overrides["COLORSPACE"] = detect_colorspace(cfg.read_text(encoding="utf-8") if cfg.exists() else "")
    if preset_name not in shader.presets:
        raise CliError(f"'{shader.id}' has no preset '{preset_name}' (available: {', '.join(shader.presets)})")
    return shader, preset_name, overrides, palette, bool(getattr(args, "legacy", False))


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_list(args) -> int:
    shaders = meta.load_all()
    if args.category:
        shaders = [s for s in shaders if s.category == args.category]
    if args.tag:
        shaders = [s for s in shaders if args.tag in s.tags]
    favs = set(state.load()["favorites"])

    def human():
        cur = None
        for s in shaders:
            if s.category != cur:
                cur = s.category
                print(c(f"\n{CATEGORIES[cur]}", "1;35"))
            star = c("★", "33") if s.id in favs else " "
            print(f" {star} {s.id:<26} {c(s.description[:70], '2')}")
        print(f"\n{len(shaders)} shaders")

    emit(args, [{"id": s.id, "name": s.name, "category": s.category, "favorite": s.id in favs} for s in shaders], human)
    return 0


def search_score(s: meta.Shader, q: str) -> float:
    q = q.lower()
    hay = " ".join([s.id, s.name.lower(), s.category, " ".join(s.tags), s.description.lower()])
    score = 0.0
    if q in s.id:
        score += 3
    if q in hay:
        score += 2
    for word in q.split():
        if word in hay:
            score += 1
        best = max((difflib.SequenceMatcher(None, word, w).ratio() for w in re.split(r"[\s,-]+", hay) if w), default=0)
        score += best
    return score


def cmd_search(args) -> int:
    q = " ".join(args.query)
    ranked = sorted(((search_score(s, q), s) for s in meta.load_all()), key=lambda x: -x[0])
    hits = [s for sc, s in ranked if sc >= 1.6][: args.limit]

    def human():
        if not hits:
            print("no matches")
        for s in hits:
            print(f"  {c(s.id, '1;36'):<34} {s.description[:80]}")

    emit(args, [{"id": s.id, "name": s.name, "category": s.category} for s in hits], human)
    return 0 if hits else 1


def cmd_info(args) -> int:
    s = meta.find(args.id)
    vals, colors = build.resolve_values(s, "balanced")

    def human():
        print(c(s.name, "1;35"), c(f"({s.id})", "2"))
        print(f"  {s.description}")
        print(f"  Category:  {CATEGORIES[s.category]}")
        print(f"  Mode:      {s.mode}{' · distorts text' if s.distorts_text else ''}{' · contains flashes' if s.flashing else ''}")
        print(f"  Tags:      {', '.join(s.tags)}")
        print(f"  Presets:   {', '.join(s.presets)}")
        print("  Colors:    " + "  ".join(f"{k.lower()}={v}" for k, v in colors.items() if k in ('PRIMARY', 'SECONDARY', 'ACCENT')))
        if s.params:
            print("  Parameters:")
            for p in s.params.values():
                print(f"    {p.name.lower():<14} {p.type:<5} default {p.default:<6} [{p.min}..{p.max}]  {p.description}")
        print("  Common parameters: intensity speed brightness saturation opacity readability quality reduced_motion reduced_flash distort_text")
        for lim in s.limitations:
            print(f"  Limitation: {lim}")
        if s.inspired_by:
            print(f"  Inspired by: {s.inspired_by}")
        print(f"  Source:    {s.rel_source()}  ({s.license}, {s.author})")

    emit(args, {
        "id": s.id, "name": s.name, "category": s.category, "description": s.description,
        "mode": s.mode, "tags": s.tags, "presets": s.presets, "colors": colors,
        "parameters": {p.name.lower(): p.to_json() for p in s.params.values()},
        "limitations": s.limitations, "source": s.rel_source(),
    }, human)
    return 0


def _install(args, shader_id: str | None) -> tuple[meta.Shader, Path, str, dict]:
    shader, preset_name, overrides, palette, legacy = resolve_build(args, shader_id)
    src = build.build_shader(shader, preset_name, overrides, palette, legacy)
    dest_dir = installed_shader_dir()
    dest = dest_dir / f"{shader.id}.glsl"
    if dest.exists() and not dest.read_text(encoding="utf-8", errors="replace").startswith(GENERATED_MARK) and not getattr(args, "force", False):
        raise CliError(f"{dest} exists and was not written by GhostFX; refusing to overwrite (use --force)")
    if getattr(args, "validate", True):
        from .validate import validate_source

        rep = validate_source(src, shader.id, webgl=False)
        if not rep.ok:
            raise CliError(f"built shader failed validation:\n{json.dumps(rep.to_json(), indent=2)}")
    if not args.dry_run:
        dest_dir.mkdir(parents=True, exist_ok=True)
        ghostty.atomic_write(dest, src)
        st = state.load()
        st["installed"][shader.id] = {"path": str(dest), "preset": preset_name, "overrides": overrides, "legacy": legacy, "version": __version__}
        state.save(st)
    return shader, dest, preset_name, overrides


def cmd_install(args) -> int:
    shader, dest, preset_name, _ = _install(args, args.id)
    emit(args, {"id": shader.id, "path": str(dest), "preset": preset_name, "dry_run": args.dry_run},
         lambda: ok_line(f"{'would install' if args.dry_run else 'installed'} {shader.id} ({preset_name}) → {dest}"))
    return 0


def _config_path(args) -> Path:
    return Path(args.config) if getattr(args, "config", None) else ghostty_config_path()


def cmd_apply(args) -> int:
    cfg = _config_path(args)
    if ghostty.is_nix_managed(cfg):
        print(ghostty.home_manager_snippet(args.id or "?", args.preset))
        warn_line(f"{cfg} is managed by Nix/Home Manager; not editing it")
        return 3
    shader, dest, preset_name, _ = _install(args, args.id)
    text = cfg.read_text(encoding="utf-8") if cfg.exists() else ""
    new = ghostty.plan_apply(text, [str(dest)], args.animation, replace_foreign=args.replace, chain=args.chain)
    if args.dry_run:
        emit(args, {"config": str(cfg), "new_config": new, "dry_run": True}, lambda: print(new))
        return 0
    b = ghostty.write_config(cfg, new)
    st = state.load()
    st["current"] = shader.id
    state.save(st)
    msg = ghostty.reload_ghostty() if not args.no_reload else "not reloading (--no-reload)"

    def human():
        ok_line(f"applied {c(shader.name, '1;35')} ({preset_name})")
        info_line(f"config: {cfg}")
        if b:
            info_line(f"backup: {b}")
        info_line(msg)

    emit(args, {"id": shader.id, "preset": preset_name, "config": str(cfg), "backup": str(b) if b else None, "reload": msg}, human)
    return 0


def cmd_export(args) -> int:
    """Write a fully built shader to a file (or stdout) without touching any config."""
    if args.colorspace is None:
        args.colorspace = "auto"
    shader, preset_name, overrides, palette, legacy = resolve_build(args, args.id)
    src = build.build_shader(shader, preset_name, overrides, palette, legacy)
    if args.output in (None, "-"):
        sys.stdout.write(src)
    else:
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        Path(args.output).write_text(src, encoding="utf-8")
        if not args.json:
            ok_line(f"wrote {args.output}")
    return 0


def cmd_current(args) -> int:
    cfg = _config_path(args)
    st = ghostty.read_state(cfg)
    cur = state.load().get("current") if st.managed_shaders else None
    data = {"config": str(cfg), "ghostfx": st.managed_shaders, "current": cur, "other_shaders": st.foreign_shaders,
            "disabled_by_ghostfx": st.disabled_shaders, "animation": st.animation, "nix_managed": st.nix_managed}

    def human():
        if cur:
            ok_line(f"current shader: {c(cur, '1;35')}")
        elif st.managed_shaders:
            info_line(f"GhostFX block present: {', '.join(st.managed_shaders)}")
        else:
            info_line("no GhostFX shader applied")
        if st.foreign_shaders:
            info_line(f"other custom-shader lines: {', '.join(st.foreign_shaders)}")
        info_line(f"config: {cfg}{' (Nix-managed)' if st.nix_managed else ''}")

    emit(args, data, human)
    return 0


def cmd_disable(args) -> int:
    cfg = _config_path(args)
    if not cfg.exists():
        info_line("no Ghostty config; nothing to disable")
        return 0
    text = cfg.read_text(encoding="utf-8")
    new = ghostty.plan_disable(text, restore=args.restore)
    if new == text:
        info_line("nothing to change")
        return 0
    if args.dry_run:
        print(new)
        return 0
    b = ghostty.write_config(cfg, new)
    st = state.load()
    st["current"] = None
    state.save(st)
    msg = ghostty.reload_ghostty() if not args.no_reload else ""
    emit(args, {"config": str(cfg), "backup": str(b) if b else None}, lambda: (ok_line("GhostFX shader disabled"), info_line(f"backup: {b}"), msg and info_line(msg)))
    return 0


def cmd_uninstall(args) -> int:
    st = state.load()
    entry = st["installed"].get(args.id)
    path = Path(entry["path"]) if entry else installed_shader_dir() / f"{args.id}.glsl"
    if not path.exists():
        info_line(f"{args.id} is not installed")
        return 0
    cfg_state = ghostty.read_state(_config_path(args))
    if str(path) in cfg_state.managed_shaders:
        raise CliError(f"{args.id} is currently applied; run `ghostfx disable` first")
    if not path.read_text(encoding="utf-8", errors="replace").startswith(GENERATED_MARK):
        raise CliError(f"{path} was not written by GhostFX; not removing it")
    if not confirm(f"Remove {path}?", args):
        warn_line("not removed (pass --yes to confirm non-interactively)")
        return 1
    if not args.dry_run:
        path.unlink()
        st["installed"].pop(args.id, None)
        state.save(st)
    ok_line(f"removed {path}")
    return 0


def cmd_categories(args) -> int:
    shaders = meta.load_all()
    counts = {k: sum(1 for s in shaders if s.category == k) for k in CATEGORIES}
    emit(args, counts, lambda: [print(f"  {k:<14} {CATEGORIES[k]:<26} {n}") for k, n in counts.items() if n])
    return 0


def cmd_palettes(args) -> int:
    pals = presets.list_palettes()
    emit(args, pals, lambda: [print(f"  {k:<18} {v['name']:<18} " + " ".join(v['colors'].get(x, '') for x in ('primary', 'secondary', 'accent'))) for k, v in pals.items()])
    return 0


def cmd_favorites(args) -> int:
    favs = state.load()["favorites"]
    emit(args, favs, lambda: print("\n".join(favs) if favs else "no favorites yet (ghostfx favorite <id>)"))
    return 0


def cmd_favorite(args) -> int:
    meta.find(args.id)
    st = state.load()
    if args.remove:
        st["favorites"] = [f for f in st["favorites"] if f != args.id]
    elif args.id not in st["favorites"]:
        st["favorites"].append(args.id)
    if not args.dry_run:
        state.save(st)
    ok_line(f"{'removed' if args.remove else 'added'} {args.id} {'from' if args.remove else 'to'} favorites")
    return 0


def cmd_random(args) -> int:
    pool = meta.load_all()
    if args.category:
        pool = [s for s in pool if s.category == args.category]
    if args.favorites:
        favs = set(state.load()["favorites"])
        pool = [s for s in pool if s.id in favs]
    if not pool:
        raise CliError("no shaders to choose from")
    s = random.choice(pool)
    if args.apply:
        args.id = s.id
        return cmd_apply(args)
    emit(args, {"id": s.id}, lambda: print(s.id))
    return 0


def cmd_preset(args) -> int:
    if args.preset_cmd == "list":
        user = presets.user_presets()
        data = {"user": {k: v.shader for k, v in user.items()}}
        if args.id:
            data["builtin"] = meta.find(args.id).presets

        def human():
            if args.id:
                print("built-in: " + ", ".join(data["builtin"]))
            print("user presets:" + ("" if user else " none"))
            for k, v in user.items():
                print(f"  {k:<20} → {v.shader} (base {v.base})")

        emit(args, data, human)
        return 0
    if args.preset_cmd == "apply":
        # `preset apply <user-preset>` or `preset apply <shader> <builtin-preset>`
        if args.builtin is None and args.target in presets.user_presets():
            args.id = None
            args.preset = args.target
        else:
            args.id = args.target
            args.preset = args.builtin or args.preset
        return cmd_apply(args)
    if args.preset_cmd == "create":
        shader = meta.find(args.shader)
        dest = user_preset_dir() / f"{args.name}.toml"
        if dest.exists() and not args.force:
            raise CliError(f"{dest} already exists (use --force)")
        text = presets.preset_template(shader, args.name, args.base)
        if not args.dry_run:
            ghostty.atomic_write(dest, text)
        ok_line(f"created {dest}")
        info_line(f"edit it, then: ghostfx preset apply {args.name}")
        return 0
    if args.preset_cmd == "show":
        user = presets.user_presets()
        if args.name not in user:
            raise CliError(f"no user preset '{args.name}'")
        print(user[args.name].path.read_text())
        return 0
    return 2


def cmd_config(args) -> int:
    cfg = _config_path(args)
    if args.config_cmd == "path":
        print(cfg)
        return 0
    if args.config_cmd == "show":
        st = ghostty.read_state(cfg)
        emit(args, st.__dict__, lambda: print(cfg.read_text() if cfg.exists() else f"(no config at {cfg})"))
        return 0
    if args.config_cmd == "edit":
        if ghostty.is_nix_managed(cfg):
            raise CliError(f"{cfg} is managed by Nix/Home Manager; edit your Nix configuration instead")
        editor = os.environ.get("VISUAL") or os.environ.get("EDITOR") or "vi"
        ghostty.backup(cfg)
        return subprocess.call([editor, str(cfg)])
    if args.config_cmd == "validate":
        problems = []
        st = ghostty.read_state(cfg)
        for pth in st.managed_shaders + st.foreign_shaders:
            if not Path(os.path.expanduser(pth)).exists():
                problems.append(f"custom-shader file missing: {pth}")
        for pth in st.managed_shaders:
            from .validate import validate_file

            rep = validate_file(Path(pth))
            if not rep.ok:
                problems.append(f"{pth}: {rep.errors or [s.log for s in rep.stages if s.ok is False]}")
        if len(st.managed_shaders) > 1:
            problems.append("more than one GhostFX shader in the managed block")
        if st.foreign_shaders and st.managed_shaders:
            problems.append("GhostFX and other custom shaders are both active; Ghostty will chain them")
        if shutil.which("ghostty"):
            out = subprocess.run(["ghostty", "+validate-config", f"--config-file={cfg}"], capture_output=True, text=True)
            if out.returncode != 0:
                problems.append("ghostty +validate-config: " + (out.stdout + out.stderr).strip())
        emit(args, {"config": str(cfg), "problems": problems}, lambda: [warn_line(p) for p in problems] or ok_line("config looks good"))
        return 1 if problems else 0
    return 2


def cmd_rollback(args) -> int:
    if args.list:
        bs = ghostty.list_backups()
        emit(args, [str(b) for b in bs], lambda: print("\n".join(str(b) for b in bs) or "no backups"))
        return 0
    src, target = ghostty.rollback(Path(args.backup) if args.backup else None, dry_run=args.dry_run)
    ok_line(f"{'would restore' if args.dry_run else 'restored'} {target} from {src}")
    if not args.dry_run and not args.no_reload:
        info_line(ghostty.reload_ghostty())
    return 0


def cmd_validate(args) -> int:
    from .validate import have_tools, validate_file, validate_source

    targets = [Path(p) for p in args.paths]
    reports = []
    if not targets:
        for s in meta.load_all():
            reports.append(validate_source(build.build_shader(s), s.id, legacy_src=build.build_shader(s, legacy=True)))
    else:
        for t in targets:
            if t.is_dir():
                for f in sorted(t.rglob("*.glsl")):
                    reports.append(validate_file(f))
            else:
                reports.append(validate_file(t))
    bad = [r for r in reports if not r.ok]

    def human():
        tools = have_tools()
        if not all(tools.values()):
            warn_line("glslangValidator/spirv-cross not found: only static checks ran (see `ghostfx doctor`)")
        for r in reports:
            mark = c("✓", "32") if r.ok else c("✗", "31")
            stages = " ".join(f"{s.stage}:{'ok' if s.ok else ('skip' if s.ok is None else 'FAIL')}" for s in r.stages)
            print(f"{mark} {r.name:<28} {c(stages, '2')}")
            for e in r.errors:
                print(f"    error: {e}")
            for w in r.warnings:
                print(f"    warning: {w}")
            for s in r.stages:
                if s.ok is False:
                    print("    " + s.log.replace("\n", "\n    "))
        print(f"\n{len(reports) - len(bad)}/{len(reports)} passed")

    emit(args, [r.to_json() for r in reports], human)
    return 1 if bad else 0


def cmd_build(args) -> int:
    root = data_root()
    out = Path(args.out) if args.out else root / "dist"
    shaders = meta.load_all() if args.all or not args.ids else [meta.find(i) for i in args.ids]
    n = 0
    for s in shaders:
        d = out / s.category
        d.mkdir(parents=True, exist_ok=True)
        (d / f"{s.id}.glsl").write_text(build.build_shader(s), encoding="utf-8")
        n += 1
        if args.presets:
            for pr in s.presets:
                if pr != "balanced":
                    (d / f"{s.id}.{pr}.glsl").write_text(build.build_shader(s, pr), encoding="utf-8")
            if args.legacy:
                (d / f"{s.id}.legacy.glsl").write_text(build.build_shader(s, legacy=True), encoding="utf-8")
        if args.preset_files:
            pd = root / "presets" / s.category
            pd.mkdir(parents=True, exist_ok=True)
            (pd / f"{s.id}.toml").write_text(presets.default_presets_toml(s), encoding="utf-8")
    ok_line(f"built {n} shaders into {out}")
    if args.manifest:
        from .manifest import write_manifest

        ok_line(f"wrote {write_manifest(root)}")
    return 0


def cmd_manifest(args) -> int:
    from .manifest import build_manifest, validate_manifest, write_manifest

    if args.check:
        path = data_root() / "manifest.json"
        data = json.loads(path.read_text())
        errs = validate_manifest(data)
        fresh = build_manifest()
        if [s["id"] for s in fresh["shaders"]] != [s["id"] for s in data["shaders"]]:
            errs.append("manifest.json is out of date (run `ghostfx manifest`)")
        for e in errs:
            warn_line(e)
        if not errs:
            ok_line(f"manifest valid ({data['shader_count']} shaders)")
        return 1 if errs else 0
    ok_line(f"wrote {write_manifest()}")
    return 0


def cmd_preview(args) -> int:
    shader, preset_name, overrides, palette, legacy = resolve_build(args, args.id)
    src = build.build_shader(shader, preset_name, overrides, palette, legacy)
    if args.window:
        exe = shutil.which("ghostty")
        if not exe:
            raise CliError("ghostty not found in PATH")
        tmp = ghostfx_home() / "preview.glsl"
        ghostty.atomic_write(tmp, src)
        info_line(f"opening a Ghostty window with {shader.id} (close it to finish)")
        return subprocess.call([exe, f"--custom-shader={tmp}", "--custom-shader-animation=always"])
    out = Path(args.out or f"{shader.id}.png")
    try:
        from .render import Renderer
    except ImportError as e:  # pragma: no cover
        raise CliError(f"offscreen preview needs moderngl/numpy/Pillow: {e}") from e
    try:
        r = Renderer(src, args.width, args.height, Path(args.terminal) if args.terminal else None, linear=overrides.get("COLORSPACE", 2) != 1)
    except Exception as e:  # noqa: BLE001
        raise CliError(f"could not create an OpenGL 4.3 context ({e}); try `ghostfx preview {shader.id} --window`") from e
    r.image(args.time).save(out)
    r.release()
    ok_line(f"wrote {out}")
    return 0


def cmd_benchmark(args) -> int:
    from .render import Renderer

    ids = [s.id for s in meta.load_all()] if args.all else args.ids
    if not ids:
        raise CliError("give shader ids or --all")
    sizes = [tuple(int(x) for x in s.split("x")) for s in args.sizes.split(",")]
    results = {}
    for sid in ids:
        s = meta.find(sid)
        src = build.build_shader(s, args.preset, {"QUALITY": PROFILES[args.quality]} if args.quality else None)
        results[sid] = {}
        for (w, h) in sizes:
            r = Renderer(src, w, h)
            res = r.benchmark(frames=args.frames)
            r.release()
            results[sid][f"{w}x{h}"] = res
            if not args.json:
                print(f"{sid:<26} {w}x{h:<6} gpu {res['gpu_ms_median']:8.3f} ms (p95 {res['gpu_ms_p95']:.3f})  [{res['renderer']}]", flush=True)
    if args.json:
        print(json.dumps(results, indent=2))
    if args.save:
        Path(args.save).write_text(json.dumps(results, indent=2) + "\n")
    return 0


def _ghostty_version() -> str | None:
    exe = shutil.which("ghostty")
    if not exe:
        return None
    try:
        out = subprocess.run([exe, "+version"], capture_output=True, text=True, timeout=10)
        m = re.search(r"Ghostty\s+(\S+)", out.stdout)
        return m.group(1) if m else out.stdout.strip().splitlines()[0]
    except (OSError, subprocess.TimeoutExpired, IndexError):
        return "unknown"


def cmd_doctor(args) -> int:
    from .validate import have_tools

    checks = []

    def add(name, ok, detail):
        checks.append({"check": name, "ok": ok, "detail": detail})

    v = _ghostty_version()
    add("ghostty", v is not None, v or "not found in PATH")
    if v and re.match(r"^1\.[0-2]\.", v):
        add("ghostty-version", False, f"{v} lacks colour/focus uniforms: use `--legacy` builds")
    cfg = ghostty_config_path()
    add("config", True, str(cfg) + ("" if cfg.exists() else " (will be created)"))
    nix = ghostty.is_nix_managed(cfg)
    add("config-writable", not nix, "managed by Nix/Home Manager: use the Home Manager module" if nix else "ok")
    text = cfg.read_text(encoding="utf-8") if cfg.exists() else ""
    add("alpha-blending", True, {1: "native (macOS default)", 2: "linear / linear-corrected"}[detect_colorspace(text)])
    st = ghostty.read_state(cfg)
    if st.foreign_shaders:
        add("other-shaders", True, "other custom-shader lines present: " + ", ".join(st.foreign_shaders))
    add("animation", True, f"custom-shader-animation = {st.animation or 'true (default: animates only while focused)'}")
    for tool, okk in have_tools().items():
        add(tool, okk, "found" if okk else "missing: install glslang / spirv-cross for full validation")
    try:
        import moderngl  # noqa: F401

        add("moderngl", True, "offscreen previews and benchmarks available")
    except ImportError:
        add("moderngl", False, "optional: pip install moderngl numpy pillow for previews/benchmarks")
    add("data", True, str(data_root()))
    add("state", True, str(ghostfx_home()))

    def human():
        for ch in checks:
            print(f"{c('✓', '32') if ch['ok'] else c('!', '33')} {ch['check']:<16} {ch['detail']}")

    emit(args, checks, human)
    return 0


def cmd_update(args) -> int:
    root = data_root()
    if (root / ".git").exists():
        info_line(f"updating git checkout at {root}")
        return subprocess.call(["git", "-C", str(root), "pull", "--ff-only"])
    if "/nix/store/" in str(root):
        print("Installed with Nix: run `nix flake update` in your flake (or `nix profile upgrade ghostfx`).")
        return 0
    print("Installed with pip: run `pip install --upgrade ghostfx` (or `pipx upgrade ghostfx`).")
    return 0


def cmd_version(args) -> int:
    emit(args, {"version": __version__, "shaders": len(meta.load_all())}, lambda: print(f"ghostfx {__version__} ({len(meta.load_all())} shaders)"))
    return 0


def cmd_generate_previews(args) -> int:
    from .previews import generate

    return generate(args)


def cmd_tui(args) -> int:
    from .tui import run

    return run(args)


# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------

def parser() -> argparse.ArgumentParser:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--json", action="store_true", help="machine-readable output")
    common.add_argument("--dry-run", action="store_true", help="show what would change without writing")
    common.add_argument("--config", help="Ghostty config file to edit (default: auto-detect)")
    common.add_argument("-y", "--yes", action="store_true", help="assume yes for confirmations")

    p = argparse.ArgumentParser(prog="ghostfx", description="GhostFX: animated GLSL shaders for Ghostty. Make your terminal another universe.")
    p.add_argument("--version", action="version", version=f"ghostfx {__version__}")
    sub = p.add_subparsers(dest="cmd")

    s = sub.add_parser("list", parents=[common], help="list shaders")
    s.add_argument("--category", choices=list(CATEGORIES))
    s.add_argument("--tag")
    s.set_defaults(fn=cmd_list)
    s = sub.add_parser("search", parents=[common], help="fuzzy search")
    s.add_argument("query", nargs="+")
    s.add_argument("--limit", type=int, default=15)
    s.set_defaults(fn=cmd_search)
    s = sub.add_parser("info", parents=[common], help="show shader details")
    s.add_argument("id")
    s.set_defaults(fn=cmd_info)
    s = sub.add_parser("preview", parents=[common], help="render a PNG preview, or open a Ghostty window with --window")
    s.add_argument("id")
    add_build_opts(s)
    s.add_argument("--window", action="store_true", help="open a temporary Ghostty window instead of rendering a PNG")
    s.add_argument("--out")
    s.add_argument("--time", type=float, default=6.0)
    s.add_argument("--width", type=int, default=1280)
    s.add_argument("--height", type=int, default=720)
    s.add_argument("--terminal", help="PNG to use as the terminal frame")
    s.set_defaults(fn=cmd_preview)
    for name, fn, hlp in (("install", cmd_install, "build a shader into ~/.config/ghostty/ghostfx/shaders"), ("apply", cmd_apply, "install and activate a shader in Ghostty")):
        s = sub.add_parser(name, parents=[common], help=hlp)
        s.add_argument("id", nargs="?")
        add_build_opts(s)
        s.add_argument("--force", action="store_true", help="overwrite a non-GhostFX file at the destination")
        if name == "apply":
            s.add_argument("--replace", action="store_true", help="comment out other custom-shader lines (restorable)")
            s.add_argument("--chain", action="store_true", help="keep other custom-shader lines (Ghostty chains them)")
            s.add_argument("--animation", choices=["true", "false", "always"], help="also set custom-shader-animation")
            s.add_argument("--no-reload", action="store_true")
        s.set_defaults(fn=fn)
    s = sub.add_parser("export", parents=[common], help="write a built shader to a file or stdout (no config changes)")
    s.add_argument("id", nargs="?")
    add_build_opts(s)
    s.add_argument("-o", "--output", help="output file (default: stdout)")
    s.set_defaults(fn=cmd_export)
    s = sub.add_parser("current", parents=[common], help="show the active shader")
    s.set_defaults(fn=cmd_current)
    s = sub.add_parser("disable", parents=[common], help="remove the GhostFX shader from the config")
    s.add_argument("--restore", action="store_true", help="also restore custom-shader lines GhostFX commented out")
    s.add_argument("--no-reload", action="store_true")
    s.set_defaults(fn=cmd_disable)
    s = sub.add_parser("uninstall", parents=[common], help="delete an installed shader build")
    s.add_argument("id")
    s.set_defaults(fn=cmd_uninstall)
    s = sub.add_parser("categories", parents=[common])
    s.set_defaults(fn=cmd_categories)
    s = sub.add_parser("palettes", parents=[common], help="list colour palettes")
    s.set_defaults(fn=cmd_palettes)
    s = sub.add_parser("favorites", parents=[common])
    s.set_defaults(fn=cmd_favorites)
    s = sub.add_parser("favorite", parents=[common], help="add (or --remove) a favorite")
    s.add_argument("id")
    s.add_argument("--remove", action="store_true")
    s.set_defaults(fn=cmd_favorite)
    s = sub.add_parser("random", parents=[common], help="pick a random shader (and --apply it)")
    s.add_argument("--category", choices=list(CATEGORIES))
    s.add_argument("--favorites", action="store_true")
    s.add_argument("--apply", action="store_true")
    add_build_opts(s)
    s.add_argument("--replace", action="store_true")
    s.add_argument("--chain", action="store_true")
    s.add_argument("--animation", choices=["true", "false", "always"])
    s.add_argument("--no-reload", action="store_true")
    s.add_argument("--force", action="store_true")
    s.set_defaults(fn=cmd_random)

    s = sub.add_parser("preset", parents=[common], help="manage presets")
    ps = s.add_subparsers(dest="preset_cmd", required=True)
    x = ps.add_parser("list", parents=[common])
    x.add_argument("id", nargs="?")
    x = ps.add_parser("apply", parents=[common], help="preset apply <shader> <preset> | preset apply <user-preset>")
    x.add_argument("target")
    x.add_argument("builtin", nargs="?", metavar="preset")
    add_build_opts(x)
    x.add_argument("--replace", action="store_true")
    x.add_argument("--chain", action="store_true")
    x.add_argument("--animation", choices=["true", "false", "always"])
    x.add_argument("--no-reload", action="store_true")
    x.add_argument("--force", action="store_true")
    x = ps.add_parser("create", parents=[common])
    x.add_argument("name")
    x.add_argument("--shader", required=True)
    x.add_argument("--base", default="balanced")
    x.add_argument("--force", action="store_true")
    x = ps.add_parser("show", parents=[common])
    x.add_argument("name")
    s.set_defaults(fn=cmd_preset)

    s = sub.add_parser("config", parents=[common], help="show/edit/validate the Ghostty config")
    s.add_argument("config_cmd", choices=["show", "edit", "validate", "path"])
    s.set_defaults(fn=cmd_config)
    s = sub.add_parser("rollback", parents=[common], help="restore the config from a GhostFX backup")
    s.add_argument("backup", nargs="?")
    s.add_argument("--list", action="store_true")
    s.add_argument("--no-reload", action="store_true")
    s.set_defaults(fn=cmd_rollback)
    s = sub.add_parser("validate", parents=[common], help="compile-check shaders through Ghostty's pipeline")
    s.add_argument("paths", nargs="*")
    s.set_defaults(fn=cmd_validate)
    s = sub.add_parser("build", parents=[common], help="(maintainers) build dist/ and preset files")
    s.add_argument("ids", nargs="*")
    s.add_argument("--all", action="store_true")
    s.add_argument("--out")
    s.add_argument("--presets", action="store_true", help="also emit subtle/cinematic builds")
    s.add_argument("--legacy", action="store_true", help="also emit Ghostty 1.2 builds (with --presets)")
    s.add_argument("--preset-files", action="store_true", help="regenerate presets/<category>/<id>.toml")
    s.add_argument("--manifest", action="store_true", help="regenerate manifest.json")
    s.set_defaults(fn=cmd_build)
    s = sub.add_parser("manifest", parents=[common], help="(maintainers) regenerate or --check manifest.json")
    s.add_argument("--check", action="store_true")
    s.set_defaults(fn=cmd_manifest)
    s = sub.add_parser("benchmark", parents=[common], help="measure GPU time offscreen")
    s.add_argument("ids", nargs="*")
    s.add_argument("--all", action="store_true")
    s.add_argument("--sizes", default="1920x1080,2560x1440,3440x1440,3840x2160")
    s.add_argument("--frames", type=int, default=60)
    s.add_argument("--preset", default="balanced")
    s.add_argument("--quality", choices=list(PROFILES))
    s.add_argument("--save")
    s.set_defaults(fn=cmd_benchmark)
    s = sub.add_parser("doctor", parents=[common], help="check the environment")
    s.set_defaults(fn=cmd_doctor)
    s = sub.add_parser("update", parents=[common], help="update GhostFX")
    s.set_defaults(fn=cmd_update)
    s = sub.add_parser("version", parents=[common])
    s.set_defaults(fn=cmd_version)
    s = sub.add_parser("generate-previews", parents=[common], help="(maintainers) render thumbnails/previews")
    s.add_argument("ids", nargs="*")
    s.add_argument("--all", action="store_true")
    s.add_argument("--backend", choices=["ghostty", "offscreen"], default="ghostty")
    s.add_argument("--animated", action="store_true", help="also record animated WebP previews")
    s.add_argument("--full", action="store_true", help="also keep full-size PNG screenshots in previews/")
    s.add_argument("--jobs", type=int, default=2)
    s.set_defaults(fn=cmd_generate_previews)
    s = sub.add_parser("tui", parents=[common], help="interactive shader browser")
    s.set_defaults(fn=cmd_tui)
    return p


def main(argv: list[str] | None = None) -> int:
    p = parser()
    args = p.parse_args(argv)
    if not getattr(args, "fn", None):
        if sys.stdin.isatty() and sys.stdout.isatty() and argv is None and len(sys.argv) == 1:
            from .tui import run

            return run(args)
        p.print_help()
        return 0
    try:
        return args.fn(args) or 0
    except (CliError, MetaError, ghostty.ConfigError) as e:
        print(c("error:", "1;31") + f" {e}", file=sys.stderr)
        return 3 if isinstance(e, ghostty.ManagedByNix) else 1
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
