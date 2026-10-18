"use client";

import { useMemo, useState } from "react";
import ShaderCard from "./ShaderCard";
import { FEATURED } from "@/lib/featured";
import type { Manifest } from "@/lib/types";

type Sort = "featured" | "name" | "category" | "recent";

export default function Gallery({ manifest }: { manifest: Manifest }) {
  const [q, setQ] = useState("");
  const [cat, setCat] = useState<string>("all");
  const [sort, setSort] = useState<Sort>("featured");
  const [calm, setCalm] = useState(false);

  const list = useMemo(() => {
    const ql = q.trim().toLowerCase();
    let xs = manifest.shaders.filter((s) => cat === "all" || s.category === cat);
    if (calm) xs = xs.filter((s) => !s.flashing && !s.distorts_text);
    if (ql) {
      const words = ql.split(/\s+/);
      xs = xs.filter((s) => {
        const hay = `${s.id} ${s.name} ${s.category_name} ${s.tags.join(" ")} ${s.description}`.toLowerCase();
        return words.every((w) => hay.includes(w));
      });
    }
    const byName = (a: { name: string }, b: { name: string }) => a.name.localeCompare(b.name);
    if (sort === "name") xs = [...xs].sort(byName);
    if (sort === "category") xs = [...xs].sort((a, b) => a.category_name.localeCompare(b.category_name) || byName(a, b));
    if (sort === "recent") xs = [...xs].sort((a, b) => b.added.localeCompare(a.added) || b.order - a.order);
    if (sort === "featured") {
      const rank = (id: string) => (FEATURED.includes(id) ? FEATURED.indexOf(id) : 1000);
      xs = [...xs].sort((a, b) => rank(a.id) - rank(b.id) || a.order - b.order);
    }
    return xs;
  }, [manifest, q, cat, sort, calm]);

  const cats = Object.entries(manifest.categories);

  return (
    <section>
      <div className="sticky top-[49px] z-10 -mx-5 mb-6 space-y-3 border-b border-line bg-ink/90 px-5 py-4 backdrop-blur">
        <div className="flex flex-wrap items-center gap-3">
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder={`Search ${manifest.shader_count} shaders… (portal, purple, calm)`}
            className="min-w-64 flex-1 rounded-lg border border-line bg-panel px-3 py-2 text-sm outline-none placeholder:text-muted focus:border-accent-strong"
            aria-label="Search shaders"
          />
          <select value={sort} onChange={(e) => setSort(e.target.value as Sort)} className="rounded-lg border border-line bg-panel px-3 py-2 text-sm" aria-label="Sort">
            <option value="featured">Featured first</option>
            <option value="recent">Recently added</option>
            <option value="name">Name</option>
            <option value="category">Category</option>
          </select>
          <label className="flex items-center gap-2 text-sm text-muted">
            <input type="checkbox" checked={calm} onChange={(e) => setCalm(e.target.checked)} /> No flashes or text distortion
          </label>
        </div>
        <div className="flex flex-wrap gap-1.5 text-xs">
          <Chip active={cat === "all"} onClick={() => setCat("all")}>All · {manifest.shader_count}</Chip>
          {cats.map(([k, v]) => (
            <Chip key={k} active={cat === k} onClick={() => setCat(k)}>{v.name} · {v.count}</Chip>
          ))}
        </div>
      </div>
      <p className="mb-4 text-xs text-muted">{list.length} shaders · hover a card for a live WebGL preview</p>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {list.map((s) => <ShaderCard key={s.id} s={s} />)}
      </div>
    </section>
  );
}

function Chip({ active, onClick, children }: { active: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      onClick={onClick}
      className={`rounded-full border px-3 py-1 transition ${active ? "border-accent-strong bg-accent-strong/20 text-fg" : "border-line text-muted hover:text-fg"}`}
    >
      {children}
    </button>
  );
}
