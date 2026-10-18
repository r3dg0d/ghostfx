/** @type {import('next').NextConfig} */
const basePath = process.env.GHOSTFX_BASE_PATH || "";

export default {
  output: "export",
  basePath,
  images: { unoptimized: true },
  trailingSlash: true,
  env: { NEXT_PUBLIC_BASE_PATH: basePath },
};
