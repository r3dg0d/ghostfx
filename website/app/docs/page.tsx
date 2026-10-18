import { manifest, REPO } from "@/lib/manifest";

export const metadata = { title: "Install · GhostFX" };

export default function Docs() {
  return (
    <article className="prose-invert mx-auto max-w-3xl space-y-6 py-10 text-sm leading-relaxed">
      <h1 className="text-3xl font-bold">Install GhostFX</h1>
      <p className="text-muted">GhostFX ships {manifest.shader_count} shaders plus a CLI that builds them with your preset, edits your Ghostty config safely (backups, rollback) and reloads Ghostty.</p>
      <Section title="Nix / NixOS">
        {`nix run github:r3dg0d/ghostfx -- list
nix profile install github:r3dg0d/ghostfx`}
      </Section>
      <Section title="Home Manager (declarative)">
        {`# flake inputs: ghostfx.url = "github:r3dg0d/ghostfx";
imports = [ inputs.ghostfx.homeManagerModules.default ];
programs.ghostty.enable = true;
programs.ghostfx = {
  enable = true;
  shader = "ender-portal";
  preset = "balanced";       # subtle | balanced | cinematic
  palette = "cyberpunk-purple";
};`}
      </Section>
      <Section title="pipx (Linux & macOS)">
        {`pipx install "git+https://github.com/r3dg0d/ghostfx"
ghostfx apply ender-portal
ghostfx tui                 # interactive browser`}
      </Section>
      <Section title="No tooling at all">
        {`# copy dist/<category>/<id>.glsl from the repository, then in your Ghostty config:
custom-shader = ~/.config/ghostty/shaders/ender-portal.glsl`}
      </Section>
      <p className="text-muted">
        Requirements: Ghostty 1.3+ (legacy builds via <code>--legacy</code> for 1.2). Full documentation:{" "}
        <a className="text-accent" href={`${REPO}#readme`}>README</a>.
      </p>
    </article>
  );
}

function Section({ title, children }: { title: string; children: string }) {
  return (
    <section>
      <h2 className="mb-2 text-lg font-semibold">{title}</h2>
      <pre className="overflow-x-auto rounded-lg border border-line bg-panel p-3 font-mono text-xs">{children}</pre>
    </section>
  );
}
