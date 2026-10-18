import Gallery from "@/components/Gallery";
import CopyButton from "@/components/CopyButton";
import { manifest } from "@/lib/manifest";

export default function Home() {
  const verified = manifest.shaders.filter((s) => s.verification.ghostty_render === "pass").length;
  return (
    <>
      <section className="py-14 text-center">
        <h1 className="font-mono text-5xl font-bold tracking-tight sm:text-6xl">
          <span className="text-accent">ghost</span>fx
        </h1>
        <p className="mt-4 text-lg text-muted">Make your terminal another universe.</p>
        <p className="mx-auto mt-2 max-w-2xl text-sm text-muted">
          {manifest.shader_count} original, animated GLSL shaders for the{" "}
          <a className="text-accent hover:underline" href="https://ghostty.org">Ghostty</a> terminal, each one tuned to keep your text
          readable. {verified} rendered and checked in Ghostty itself.
        </p>
        <div className="mx-auto mt-8 flex max-w-xl flex-col gap-2 text-left">
          <CopyButton text="nix run github:r3dg0d/ghostfx -- apply ender-portal" />
          <CopyButton text='pipx install "git+https://github.com/r3dg0d/ghostfx" && ghostfx apply ender-portal' />
        </div>
      </section>
      <Gallery manifest={manifest} />
    </>
  );
}
