# Home Manager module for GhostFX.
#
#   programs.ghostfx = {
#     enable = true;
#     shader = "ender-portal";
#     preset = "balanced";
#   };
#
# The shader is compiled at build time into the Nix store and wired into
# Ghostty through Home Manager's own `programs.ghostty.settings`
# (custom-shader is a repeatable key there). If you do not use
# `programs.ghostty`, set `ghosttyIntegration = false` and reference
# `config.programs.ghostfx.shaderPath` yourself.
self:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ghostfx;
  inherit (lib) mkOption mkEnableOption mkIf types literalExpression;

  fmt = v:
    if builtins.isBool v then (if v then "true" else "false")
    else toString v;

  args = lib.concatStringsSep " " (
    [ (lib.escapeShellArg cfg.shader) "--preset" (lib.escapeShellArg cfg.preset) "--colorspace" cfg.colorspace ]
    ++ lib.optionals (cfg.palette != null) [ "--palette" (lib.escapeShellArg cfg.palette) ]
    ++ lib.optionals (cfg.quality != null) [ "--quality" cfg.quality ]
    ++ lib.optional cfg.reducedMotion "--reduced-motion"
    ++ lib.optional cfg.reducedFlash "--reduced-flash"
    ++ lib.optional cfg.highReadability "--high-readability"
    ++ lib.optional (!cfg.distortText) "--no-distort"
    ++ lib.optional cfg.legacy "--legacy"
    ++ lib.concatMap (k: [ "--set" (lib.escapeShellArg "${k}=${fmt cfg.settings.${k}}") ]) (builtins.attrNames cfg.settings)
  );

  built = pkgs.runCommand "ghostfx-${cfg.shader}-${cfg.preset}.glsl"
    { nativeBuildInputs = [ cfg.package ]; }
    ''
      export HOME=$TMPDIR
      ghostfx export ${args} -o $out
    '';
in
{
  options.programs.ghostfx = {
    enable = mkEnableOption "GhostFX shaders for Ghostty";

    package = mkOption {
      type = types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.ghostfx;
      defaultText = literalExpression "ghostfx.packages.\${system}.ghostfx";
      description = "The GhostFX package (also added to home.packages for the CLI).";
    };

    shader = mkOption {
      type = types.str;
      example = "ender-portal";
      description = "Shader id (see `ghostfx list`).";
    };

    preset = mkOption {
      type = types.str;
      default = "balanced";
      description = "Built-in preset: subtle, balanced, cinematic, or a shader-specific one.";
    };

    palette = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "cyberpunk-purple";
      description = "Optional palette from GhostFX's themes/ directory.";
    };

    quality = mkOption {
      type = types.nullOr (types.enum [ "eco" "balanced" "ultra" ]);
      default = null;
      description = "Performance profile.";
    };

    colorspace = mkOption {
      type = types.enum [ "auto" "native" "linear" ];
      default = if pkgs.stdenv.hostPlatform.isDarwin then "native" else "linear";
      description = ''
        Must match Ghostty's `alpha-blending` (native -> "native",
        linear / linear-corrected -> "linear"). Defaults follow Ghostty's
        platform defaults.
      '';
    };

    reducedMotion = mkOption { type = types.bool; default = false; description = "Slow all motion to 20%."; };
    reducedFlash = mkOption { type = types.bool; default = false; description = "Attenuate flashes and strobing."; };
    highReadability = mkOption { type = types.bool; default = false; description = "Maximum text protection."; };
    distortText = mkOption { type = types.bool; default = true; description = "Allow effects to move or warp terminal text."; };
    legacy = mkOption { type = types.bool; default = false; description = "Build for Ghostty 1.2."; };

    settings = mkOption {
      type = types.attrsOf (types.oneOf [ types.bool types.int types.float types.str ]);
      default = { };
      example = literalExpression ''{ intensity = 0.45; speed = 0.8; primary = "#8B5CF6"; }'';
      description = "Extra parameter overrides passed as `--set key=value`.";
    };

    animation = mkOption {
      type = types.nullOr (types.enum [ "true" "false" "always" ]);
      default = null;
      description = "Optionally set Ghostty's custom-shader-animation.";
    };

    ghosttyIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Add the shader to programs.ghostty.settings.custom-shader.";
    };

    shaderPath = mkOption {
      type = types.path;
      readOnly = true;
      default = built;
      defaultText = literalExpression "<built shader in the Nix store>";
      description = "Path of the built shader, for manual wiring.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    programs.ghostty.settings = mkIf cfg.ghosttyIntegration (
      { custom-shader = [ "${built}" ]; }
      // lib.optionalAttrs (cfg.animation != null) { custom-shader-animation = cfg.animation; }
    );
  };
}
