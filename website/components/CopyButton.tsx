"use client";

import { useState } from "react";

export default function CopyButton({ text, label }: { text: string; label?: string }) {
  const [done, setDone] = useState(false);
  return (
    <div className="flex items-center gap-2 rounded-lg border border-line bg-panel px-3 py-2 font-mono text-xs">
      <span className="select-all truncate text-fg/90">
        <span className="text-accent">$ </span>
        {text}
      </span>
      <button
        onClick={() => {
          navigator.clipboard?.writeText(text).then(() => {
            setDone(true);
            setTimeout(() => setDone(false), 1500);
          });
        }}
        className="ml-auto shrink-0 rounded border border-line px-2 py-0.5 text-[11px] text-muted hover:border-accent-strong hover:text-fg"
        aria-label={label ?? "Copy command"}
      >
        {done ? "copied" : "copy"}
      </button>
    </div>
  );
}
