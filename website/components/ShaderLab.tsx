"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import ShaderCanvas from "./ShaderCanvas";
import CopyButton from "./CopyButton";
import { asset } from "@/lib/manifest";
import { applyValues, toWebGL, type Values } from "@/lib/glsl";
import type { ShaderEntry } from "@/lib/types";

const SLIDERS = ["INTENSITY", "SPEED", "BRIGHTNESS", "SATURATION", "READABILITY"];
const TOGGLES = ["REDUCED_MOTION", "REDUCED_FLASH", "DISTORT_TEXT"];
const QUALITY = ["eco", "balanced", "ultra"];

export default function ShaderLab({ s }: { s: ShaderEntry }) {
  const defaults = useMemo(() => {
    const v: Values = {};
    for (const p of s.parameters) v[p.name] = p.default;
    for (const k of ["PRIMARY", "SECONDARY", "ACCENT"]) v[k] = s.colors[k];
    return v;
  }, [s]);
  const intNames = useMemo(() => new Set(s.parameters.filter((p) => p.type === "int").map((p) => p.name)), [s]);
  const [preset, setPreset] = useState("balanced");
  const [values, setValues] = useState<Values>(defaults);
  const [built, setBuilt] = useState<{ prefix: string; src: string } | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [playing, setPlaying] = useState(true);

  useEffect(() => {
    Promise.all([fetch(asset("webgl-prefix.glsl")).then((r) => r.text()), fetch(asset(`shaders/${s.id}.glsl`)).then((r) => r.text())])
      .then(([prefix, src]) => setBuilt({ prefix, src }));
  }, [s.id]);

  const choosePreset = (name: string) => {
    setPreset(name);
    setValues({ ...defaults, ...(s.preset_values?.[name] ?? {}) });
  };

  const source = useMemo(() => (built ? toWebGL(built.prefix, applyValues(built.src, values, intNames)) : null), [built, values, intNames]);
  const set = (k: string, v: number | string) => setValues((old) => ({ ...old, [k]: v }));
  const onError = useCallback((m: string | null) => setError(m), []);

  // CLI command reproducing the current state.
  const command = useMemo(() => {
    const parts = [`ghostfx apply ${s.id}`];
    if (preset !== "balanced") parts.push(`--preset ${preset}`);
    const base = { ...defaults, ...(s.preset_values?.[preset] ?? {}) };
    for (const [k, v] of Object.entries(values)) {
      if (k.startsWith("COLORSPACE")) continue;
      if (String(base[k]) !== String(v)) parts.push(`--set ${k.toLowerCase()}=${v}`);
    }
    return parts.join(" ");
  }, [values, preset, defaults, s]);

  const param = (name: string) => s.parameters.find((p) => p.name === name)!;
  const own = s.parameters.filter((p) => !p.common);

  return (
    <div className="grid gap-6 lg:grid-cols-[1fr_320px]">
      <div>
        <div className="relative aspect-video overflow-hidden rounded-xl border border-line bg-black glow">
          {source && <ShaderCanvas source={source} playing={playing} className="h-full w-full" onError={onError} />}
          {error && (
            <div className="absolute inset-0 grid place-items-center bg-black/80 p-6 text-center text-xs text-red-300">
              <div>
                <p className="mb-2">Live preview unavailable in this browser.</p>
                <pre className="max-h-40 overflow-auto whitespace-pre-wrap text-left text-[10px] text-muted">{error}</pre>
              </div>
            </div>
          )}
        </div>
        <div className="mt-3 flex flex-wrap items-center gap-2 text-xs">
          {s.presets.map((p) => (
            <button key={p} onClick={() => choosePreset(p)} className={`rounded-full border px-3 py-1 capitalize ${preset === p ? "border-accent-strong bg-accent-strong/20" : "border-line text-muted hover:text-fg"}`}>
              {p}
            </button>
          ))}
          <button onClick={() => setPlaying((x) => !x)} className="ml-auto rounded-full border border-line px-3 py-1 text-muted hover:text-fg">
            {playing ? "❚❚ pause" : "▶ play"}
          </button>
          <button onClick={() => choosePreset(preset)} className="rounded-full border border-line px-3 py-1 text-muted hover:text-fg">reset</button>
        </div>
        <div className="mt-4"><CopyButton text={command} /></div>
        <p className="mt-2 text-[11px] text-muted">
          Browser preview: WebGL2 approximation over a real Ghostty capture. Ghostty itself renders through OpenGL (Linux) or Metal (macOS).
        </p>
      </div>

      <aside className="space-y-5 rounded-xl border border-line bg-panel p-4 text-sm">
        <Group title="Look">
          {SLIDERS.map((k) => <Slider key={k} p={param(k)} v={Number(values[k])} onChange={(v) => set(k, v)} />)}
          <label className="flex items-center justify-between gap-2 text-xs">
            <span className="text-muted">quality</span>
            <select value={QUALITY[Number(values.QUALITY)]} onChange={(e) => set("QUALITY", QUALITY.indexOf(e.target.value))} className="rounded border border-line bg-ink px-2 py-1">
              {QUALITY.map((q) => <option key={q}>{q}</option>)}
            </select>
          </label>
        </Group>
        {own.length > 0 && (
          <Group title="Shader parameters">
            {own.map((p) => p.type === "bool"
              ? <Toggle key={p.name} label={p.name.toLowerCase()} v={Number(values[p.name]) > 0.5} onChange={(b) => set(p.name, b ? 1 : 0)} />
              : <Slider key={p.name} p={p} v={Number(values[p.name])} onChange={(v) => set(p.name, v)} />)}
          </Group>
        )}
        <Group title="Colours">
          {["PRIMARY", "SECONDARY", "ACCENT"].map((k) => (
            <label key={k} className="flex items-center justify-between text-xs">
              <span className="text-muted">{k.toLowerCase()}</span>
              <input type="color" value={String(values[k])} onChange={(e) => set(k, e.target.value.toUpperCase())} className="h-6 w-12 cursor-pointer rounded border border-line bg-transparent" />
            </label>
          ))}
        </Group>
        <Group title="Accessibility">
          {TOGGLES.map((k) => <Toggle key={k} label={k.toLowerCase()} v={Number(values[k]) > 0.5} onChange={(b) => set(k, b ? 1 : 0)} />)}
        </Group>
      </aside>
    </div>
  );
}

function Group({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <h3 className="mb-2 text-[11px] font-semibold uppercase tracking-wider text-muted">{title}</h3>
      <div className="space-y-2">{children}</div>
    </div>
  );
}

function Slider({ p, v, onChange }: { p: { name: string; min: number; max: number; type: string; description: string }; v: number; onChange: (v: number) => void }) {
  const step = p.type === "int" ? 1 : (p.max - p.min) / 100;
  return (
    <label className="block text-xs" title={p.description}>
      <span className="flex justify-between text-muted"><span>{p.name.toLowerCase()}</span><span className="font-mono text-fg/80">{p.type === "int" ? v : v.toFixed(2)}</span></span>
      <input type="range" min={p.min} max={p.max} step={step} value={v} onChange={(e) => onChange(Number(e.target.value))} className="w-full" />
    </label>
  );
}

function Toggle({ label, v, onChange }: { label: string; v: boolean; onChange: (b: boolean) => void }) {
  return (
    <label className="flex items-center justify-between text-xs">
      <span className="text-muted">{label}</span>
      <input type="checkbox" checked={v} onChange={(e) => onChange(e.target.checked)} />
    </label>
  );
}
