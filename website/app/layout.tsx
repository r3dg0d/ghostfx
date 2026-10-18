import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";
import { manifest, REPO } from "@/lib/manifest";

export const metadata: Metadata = {
  title: "GhostFX — animated shaders for Ghostty",
  description: `${manifest.shader_count} open-source animated GLSL shaders for the Ghostty terminal. Make your terminal another universe.`,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen font-sans antialiased">
        <header className="sticky top-0 z-20 border-b border-line bg-ink/80 backdrop-blur">
          <nav className="mx-auto flex max-w-7xl items-center gap-6 px-5 py-3 text-sm">
            <Link href="/" className="font-mono text-base font-bold tracking-tight">
              <span className="text-accent">ghost</span>fx
            </Link>
            <Link href="/" className="text-muted hover:text-fg">Gallery</Link>
            <Link href="/docs/" className="text-muted hover:text-fg">Install</Link>
            <a href={REPO} className="ml-auto text-muted hover:text-fg">GitHub ↗</a>
          </nav>
        </header>
        <main className="mx-auto max-w-7xl px-5 pb-24">{children}</main>
        <footer className="border-t border-line py-8 text-center text-xs text-muted">
          GhostFX · MIT licensed · browser previews are WebGL approximations of Ghostty&apos;s renderer
        </footer>
      </body>
    </html>
  );
}
