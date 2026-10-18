"use client";

import { useEffect, useRef, useState } from "react";
import { asset } from "@/lib/manifest";

const VERT = `#version 300 es
in vec2 pos;
void main() { gl_Position = vec4(pos, 0.0, 1.0); }`;

let prefixCache: Promise<string> | null = null;
const getPrefix = () => (prefixCache ??= fetch(asset("webgl-prefix.glsl")).then((r) => r.text()));

let termImage: Promise<HTMLImageElement> | null = null;
const getTerminal = () =>
  (termImage ??= new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = reject;
    img.src = asset("terminal.png");
  }));

interface Props {
  source: string | null;          // full WebGL fragment source
  playing?: boolean;
  className?: string;
  maxDpr?: number;
  onError?: (msg: string | null) => void;
  startTime?: number;
}

/**
 * Renders a GhostFX shader with the Ghostty uniform set emulated in WebGL2.
 * iChannel0 is a real Ghostty capture of a terminal session. Browser output
 * is an approximation of what Ghostty renders.
 */
export default function ShaderCanvas({ source, playing = true, className, maxDpr = 1.5, onError, startTime = 6 }: Props) {
  const canvas = useRef<HTMLCanvasElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const el = canvas.current;
    if (!el) return;
    const io = new IntersectionObserver(([e]) => setVisible(e.isIntersecting), { rootMargin: "100px" });
    io.observe(el);
    return () => io.disconnect();
  }, []);

  useEffect(() => {
    const el = canvas.current;
    if (!el || !source || !visible) return;
    const gl = el.getContext("webgl2", { premultipliedAlpha: true, antialias: false });
    if (!gl) {
      onError?.("WebGL2 is not available in this browser.");
      return;
    }
    let raf = 0;
    let disposed = false;
    const owned: { prog?: WebGLProgram; buf?: WebGLBuffer | null; tex?: WebGLTexture | null } = {};
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    const compile = (type: number, src: string) => {
      const sh = gl.createShader(type)!;
      gl.shaderSource(sh, src);
      gl.compileShader(sh);
      if (!gl.getShaderParameter(sh, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(sh) || "compile error");
      return sh;
    };

    (async () => {
      try {
        const img = await getTerminal();
        if (disposed) return;
        const prog = (owned.prog = gl.createProgram()!);
        gl.attachShader(prog, compile(gl.VERTEX_SHADER, VERT));
        gl.attachShader(prog, compile(gl.FRAGMENT_SHADER, source));
        gl.bindAttribLocation(prog, 0, "pos");
        gl.linkProgram(prog);
        if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(prog) || "link error");
        onError?.(null);
        gl.useProgram(prog);
        const buf = (owned.buf = gl.createBuffer());
        gl.bindBuffer(gl.ARRAY_BUFFER, buf);
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);

        const tex = (owned.tex = gl.createTexture());
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        const u = (n: string) => gl.getUniformLocation(prog, n);
        gl.uniform1i(u("iChannel0"), 0);
        gl.uniform3f(u("iBackgroundColor"), 0x28 / 255, 0x2c / 255, 0x34 / 255);
        gl.uniform3f(u("iForegroundColor"), 1, 1, 1);
        gl.uniform3f(u("iCursorColor"), 1, 1, 1);
        gl.uniform1i(u("iFocus"), 1);
        gl.uniform1f(u("iTimeFocus"), -100);
        gl.uniform1i(u("iCursorVisible"), 1);
        const uRes = u("iResolution"), uTime = u("iTime"), uFrame = u("iFrame"), uDelta = u("iTimeDelta");

        const t0 = performance.now();
        let frame = 0, last = t0;
        const draw = (now: number) => {
          if (disposed) return;
          const dpr = Math.min(window.devicePixelRatio || 1, maxDpr);
          const w = Math.round(el.clientWidth * dpr), h = Math.round(el.clientHeight * dpr);
          if (el.width !== w || el.height !== h) { el.width = w; el.height = h; }
          gl.viewport(0, 0, w, h);
          const t = playing && !reduce ? startTime + (now - t0) / 1000 : startTime;
          gl.uniform3f(uRes, w, h, 1);
          gl.uniform1f(uTime, t);
          gl.uniform1f(uDelta, (now - last) / 1000);
          gl.uniform1i(uFrame, frame++);
          last = now;
          gl.drawArrays(gl.TRIANGLES, 0, 3);
          if (playing && !reduce) raf = requestAnimationFrame(draw);
        };
        raf = requestAnimationFrame(draw);
      } catch (e) {
        onError?.(String((e as Error).message || e));
      }
    })();

    return () => {
      disposed = true;
      cancelAnimationFrame(raf);
      if (owned.prog) gl.deleteProgram(owned.prog);
      if (owned.buf) gl.deleteBuffer(owned.buf);
      if (owned.tex) gl.deleteTexture(owned.tex);
    };
  }, [source, visible, playing, maxDpr, onError, startTime]);

  // Release the context when the canvas goes away (gallery cards come and go).
  useEffect(() => {
    const el = canvas.current;
    return () => {
      el?.getContext("webgl2")?.getExtension("WEBGL_lose_context")?.loseContext();
    };
  }, []);

  return <canvas ref={canvas} className={className} />;
}

export async function loadWebGLSource(id: string): Promise<string> {
  const [prefix, built] = await Promise.all([getPrefix(), fetch(asset(`shaders/${id}.glsl`)).then((r) => r.text())]);
  const { toWebGL } = await import("@/lib/glsl");
  return toWebGL(prefix, built);
}
