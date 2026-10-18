import Link from "next/link";
import { notFound } from "next/navigation";
import ShaderLab from "@/components/ShaderLab";
import { asset, getShader, manifest, REPO } from "@/lib/manifest";

export function generateStaticParams() {
  return manifest.shaders.map((s) => ({ id: s.id }));
}

export async function generateMetadata({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const s = getShader(id);
  return { title: s ? `${s.name} · GhostFX` : "GhostFX", description: s?.description };
}

const status = (v: string) => ({ verified: "Verified in Ghostty", "compiles-msl": "Compiles to Metal (untested on a Mac)", compiles: "Compiles", unknown: "Unknown" }[v] ?? v);

export default async function ShaderPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const s = getShader(id);
  if (!s) notFound();
  const v = s.verification;
  const bench = s.benchmark as { status?: string; note?: string; results?: Record<string, { gpu_ms_median: number }> };
  const rows: [string, React.ReactNode][] = [
    ["Shader", s.name],
    ["Category", s.category_name],
    ["Author", s.author],
    ["License", s.license],
    ["Mode", `${s.mode}${s.distorts_text ? " · can distort text" : ""}`],
    ["Presets", s.presets.join(" / ")],
    ["Linux", status(s.platforms.linux)],
    ["macOS", status(s.platforms.macos)],
    ["Ghostty check", v.ghostty_render === "pass" ? `rendered in Ghostty ${v.ghostty_version} (${v.checked})${v.animates ? ", animates" : ""}` : v.ghostty_render],
    ["Text contrast", v.readability_contrast ? `${v.readability_contrast}:1 (measured, balanced preset)` : "not measured"],
    ["Performance", bench.status === "measured" && bench.results ? Object.entries(bench.results).map(([k, r]) => `${k}: ${r.gpu_ms_median} ms`).join(" · ") + (bench.note ? ` — ${bench.note}` : "") : "Not yet benchmarked on GPU hardware"],
    ["Requires", `Ghostty ≥ ${s.min_ghostty} (legacy builds available for 1.2)`],
  ];
  return (
    <div className="py-8">
      <Link href="/" className="text-xs text-muted hover:text-fg">← Gallery</Link>
      <div className="mt-3 mb-6">
        <h1 className="text-3xl font-bold">{s.name}</h1>
        <p className="mt-2 max-w-3xl text-muted">{s.description}</p>
        <div className="mt-3 flex flex-wrap gap-1.5">
          {s.tags.map((t) => <span key={t} className="rounded-full border border-line px-2 py-0.5 text-[11px] text-muted">#{t}</span>)}
          {s.flashing && <span className="rounded-full border border-amber-500/40 px-2 py-0.5 text-[11px] text-amber-300">contains flashes · use --reduced-flash</span>}
        </div>
      </div>
      <ShaderLab s={s} />
      <div className="mt-10 grid gap-6 md:grid-cols-2">
        <table className="w-full text-sm">
          <tbody>
            {rows.map(([k, val]) => (
              <tr key={k} className="border-b border-line/60">
                <td className="w-36 py-2 pr-4 align-top text-muted">{k}</td>
                <td className="py-2">{val}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="space-y-3 text-sm">
          <h2 className="font-semibold">Use it</h2>
          <pre className="overflow-x-auto rounded-lg border border-line bg-panel p-3 font-mono text-xs leading-relaxed">{`ghostfx apply ${s.id}                 # balanced
ghostfx apply ${s.id} --preset subtle  # everyday coding
ghostfx apply ${s.id} --quality eco --reduced-motion

# Home Manager
programs.ghostfx = { enable = true; shader = "${s.id}"; };

# Or without the CLI: download the .glsl and add
custom-shader = /path/to/${s.id}.glsl`}</pre>
          <div className="flex flex-wrap gap-3 text-xs">
            <a className="rounded border border-line px-3 py-1.5 hover:border-accent-strong" href={asset(`shaders/${s.id}.glsl`)} download>Download .glsl (balanced)</a>
            <a className="rounded border border-line px-3 py-1.5 hover:border-accent-strong" href={`${REPO}/blob/main/${s.source}`}>Source ↗</a>
            <a className="rounded border border-line px-3 py-1.5 hover:border-accent-strong" href={`${REPO}/blob/main/presets/${s.category}/${s.id}.toml`}>Presets ↗</a>
          </div>
          {s.known_limitations.length > 0 && (
            <div className="text-xs text-muted">
              <h3 className="mt-4 font-semibold text-fg">Known limitations</h3>
              <ul className="list-disc pl-5">{s.known_limitations.map((l) => <li key={l}>{l}</li>)}</ul>
            </div>
          )}
          {s.attribution && <p className="text-xs text-muted">Inspired by: {s.attribution}</p>}
        </div>
      </div>
    </div>
  );
}
