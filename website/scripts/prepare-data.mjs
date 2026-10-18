// Copies the manifest, built shaders, thumbnails and the terminal fixture
// from the repository into public/ so the static site is self-contained.
import { cpSync, existsSync, mkdirSync, readFileSync, rmSync, writeFileSync, copyFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "..", "..");
const pub = resolve(here, "..", "public");
const out = join(pub, "data");

rmSync(out, { recursive: true, force: true });
mkdirSync(join(out, "shaders"), { recursive: true });

const manifest = JSON.parse(readFileSync(join(root, "manifest.json"), "utf8"));
for (const s of manifest.shaders) {
  const src = join(root, s.dist);
  if (!existsSync(src)) throw new Error(`missing ${s.dist}; run \`ghostfx build --all\``);
  copyFileSync(src, join(out, "shaders", `${s.id}.glsl`));
}
writeFileSync(join(out, "manifest.json"), JSON.stringify(manifest));
copyFileSync(join(root, "compat", "webgl-prefix.glsl"), join(out, "webgl-prefix.glsl"));
copyFileSync(join(root, "tests", "fixtures", "terminal-1280x720.png"), join(out, "terminal.png"));
if (existsSync(join(root, "thumbnails"))) cpSync(join(root, "thumbnails"), join(out, "thumbnails"), { recursive: true });
if (existsSync(join(root, "previews"))) cpSync(join(root, "previews"), join(out, "previews"), { recursive: true });
// The manifest is also imported at build time by the pages.
mkdirSync(join(here, "..", "lib", "generated"), { recursive: true });
writeFileSync(join(here, "..", "lib", "generated", "manifest.json"), JSON.stringify(manifest));
console.log(`prepared ${manifest.shaders.length} shaders`);
