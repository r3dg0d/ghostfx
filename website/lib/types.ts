export interface Param {
  name: string;
  type: "float" | "int" | "bool";
  default: number;
  min: number;
  max: number;
  description: string;
  common: boolean;
}

export interface ShaderEntry {
  id: string;
  name: string;
  category: string;
  category_name: string;
  description: string;
  author: string;
  license: string;
  version: string;
  source: string;
  dist: string;
  mode: string;
  animated: boolean;
  flashing: boolean;
  distorts_text: boolean;
  presets: string[];
  preset_values: Record<string, Record<string, number | string>>;
  tags: string[];
  colors: Record<string, string>;
  parameters: Param[];
  required_capabilities: string[];
  min_ghostty: string;
  known_limitations: string[];
  attribution: string | null;
  platforms: { linux: string; macos: string };
  verification: {
    compile: string;
    ghostty_render: string;
    animates: boolean | null;
    readability_contrast: number | null;
    ghostty_version: string | null;
    checked: string | null;
  };
  benchmark: Record<string, unknown>;
  previews: Record<string, string>;
  order: number;
  added: string;
}

export interface Manifest {
  shader_count: number;
  common_parameters: Param[];
  categories: Record<string, { name: string; count: number }>;
  shaders: ShaderEntry[];
}
