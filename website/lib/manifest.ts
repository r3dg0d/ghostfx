import data from "./generated/manifest.json";
import type { Manifest, ShaderEntry } from "./types";

export const manifest = data as unknown as Manifest;

/** Shader entry with the shared common parameters merged in. */
export function getShader(id: string): ShaderEntry | undefined {
  const s = manifest.shaders.find((x) => x.id === id);
  return s && { ...s, parameters: [...manifest.common_parameters, ...s.parameters] };
}

export const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";
export const asset = (p: string) => `${basePath}/data/${p}`;
export const REPO = "https://github.com/r3dg0d/ghostfx";
