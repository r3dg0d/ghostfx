# Minimal standalone Home Manager setup using GhostFX.
#   home-manager switch --flake .#me
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostfx = {
      url = "github:r3dg0d/ghostfx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ghostfx, ... }: {
    homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ghostfx.homeManagerModules.default
        {
          home.username = "me";
          home.homeDirectory = "/home/me";
          home.stateVersion = "25.11";

          programs.ghostty = {
            enable = true;
            settings = {
              font-size = 13;
              theme = "catppuccin-mocha";
            };
          };

          programs.ghostfx = {
            enable = true;
            shader = "ender-portal";
            preset = "balanced";
            # palette = "cyberpunk-purple";
            # quality = "eco";
            # reducedMotion = true;
            # settings = { intensity = 0.45; primary = "#8B5CF6"; };
          };
        }
      ];
    };
  };
}
