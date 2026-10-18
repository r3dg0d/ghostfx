// Turn a GhostFX build into WebGL2 source and override its #defines.

export type Values = Record<string, number | string>;

function hexToVec3(hex: string): string {
  const h = hex.replace("#", "");
  const c = [0, 2, 4].map((i) => (parseInt(h.slice(i, i + 2), 16) / 255).toFixed(4));
  return `vec3(${c.join(", ")})`;
}

function fmtFloat(v: number): string {
  const s = String(v);
  return s.includes(".") || s.includes("e") ? s : `${s}.0`;
}

/** Replace `#define GFX_X ...` / `#define P_X ...` lines with new values. */
export function applyValues(src: string, values: Values, intNames: Set<string>): string {
  let out = src;
  for (const [key, val] of Object.entries(values)) {
    const isColor = typeof val === "string" && val.startsWith("#");
    for (const prefix of ["GFX_", "P_"]) {
      const re = new RegExp(`^#define ${prefix}${key} .*$`, "m");
      if (!re.test(out)) continue;
      const lit = isColor ? hexToVec3(val as string) : intNames.has(key) ? String(Math.round(Number(val))) : fmtFloat(Number(val));
      out = out.replace(re, `#define ${prefix}${key} ${lit}`);
    }
  }
  return out;
}

/** The browser canvas is not sRGB-encoded, so use "native" colour handling. */
export function toWebGL(prefix: string, built: string): string {
  const body = built.replace(/^#define GFX_COLORSPACE .*$/m, "#define GFX_COLORSPACE 1");
  return `${prefix}\n${body}`;
}
