"use client";

import Link from "next/link";
import { useState } from "react";
import ShaderCanvas, { loadWebGLSource } from "./ShaderCanvas";
import { asset } from "@/lib/manifest";
import type { ShaderEntry } from "@/lib/types";

export default function ShaderCard({ s }: { s: ShaderEntry }) {
  const [src, setSrc] = useState<string | null>(null);
  const [hover, setHover] = useState(false);
  const thumb = s.previews.thumbnail ? asset(s.previews.thumbnail) : null;

  const start = () => {
    setHover(true);
    if (!src) loadWebGLSource(s.id).then(setSrc).catch(() => undefined);
  };

  return (
    <Link
      href={`/shader/${s.id}/`}
      onMouseEnter={start}
      onMouseLeave={() => setHover(false)}
      onFocus={start}
      onBlur={() => setHover(false)}
      className="group block overflow-hidden rounded-xl border border-line bg-panel transition hover:border-accent-strong/60 hover:glow focus:outline-none focus-visible:ring-2 focus-visible:ring-accent"
    >
      <div className="relative aspect-video bg-black">
        {thumb ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={thumb} alt={`${s.name} preview`} loading="lazy" className="absolute inset-0 h-full w-full object-cover" />
        ) : (
          <div className="absolute inset-0 grid place-items-center text-xs text-muted">no preview yet</div>
        )}
        {hover && src && <ShaderCanvas source={src} className="absolute inset-0 h-full w-full" maxDpr={1} />}
        <div className="absolute left-2 top-2 flex gap-1">
          {s.verification.ghostty_render === "pass" && (
            <span title={`Rendered in Ghostty ${s.verification.ghostty_version ?? ""}`} className="rounded bg-black/70 px-1.5 py-0.5 text-[10px] text-emerald-300">
              ✓ Ghostty
            </span>
          )}
          {s.flashing && <span title="Contains flashes (use --reduced-flash)" className="rounded bg-black/70 px-1.5 py-0.5 text-[10px] text-amber-300">⚡ flashes</span>}
        </div>
      </div>
      <div className="p-3">
        <div className="flex items-baseline justify-between gap-2">
          <h3 className="truncate font-medium">{s.name}</h3>
          <span className="shrink-0 text-[11px] text-muted">{s.category_name}</span>
        </div>
        <p className="mt-1 line-clamp-2 text-xs text-muted">{s.description}</p>
      </div>
    </Link>
  );
}
