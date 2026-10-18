{
  description = "GhostFX: 180+ animated GLSL shaders for the Ghostty terminal";

  # The channel tarball supports immutable lock URLs, like github:NixOS/nixpkgs.
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs: rec {
        ghostfx = pkgs.callPackage ./nix/package.nix { src = self; };
        # Pre-built shaders (every shader x every built-in preset) for
        # declarative setups that do not want to run the CLI at all.
        shaders = pkgs.callPackage ./nix/shaders.nix { inherit ghostfx; };
        default = ghostfx;
      });

      apps = forAll (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.ghostfx}/bin/ghostfx";
        };
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            (python3.withPackages (ps: with ps; [ pytest moderngl numpy pillow ]))
            glslang
            spirv-cross
            ruff
            nodejs_22
            ffmpeg
          ] ++ lib.optionals stdenv.hostPlatform.isLinux [ xvfb-run ghostty ];
          shellHook = ''
            export GHOSTFX_DATA=$PWD
            export PYTHONPATH=$PWD/tools''${PYTHONPATH:+:$PYTHONPATH}
            echo "GhostFX dev shell: python3 -m ghostfx --help"
          '';
        };
      });

      checks = forAll (pkgs: {
        # Compiles every shader through Ghostty's pipeline (glslang -> SPIR-V ->
        # SPIRV-Cross GLSL 430 + MSL) and checks the manifest.
        shaders = pkgs.runCommand "ghostfx-validate"
          { nativeBuildInputs = [ self.packages.${pkgs.system}.ghostfx pkgs.glslang pkgs.spirv-cross ]; }
          ''
            export HOME=$TMPDIR
            ghostfx validate --json > report.json
            ghostfx manifest --check
            touch $out
          '';
      });

      homeManagerModules.ghostfx = import ./nix/hm-module.nix self;
      homeManagerModules.default = self.homeManagerModules.ghostfx;

      overlays.default = final: prev: {
        ghostfx = final.callPackage ./nix/package.nix { src = self; };
      };
    };
}
