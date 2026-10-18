# NixOS module snippet: Home Manager as a NixOS module, with GhostFX.
# In your system flake, add `ghostfx` as an input and pass it through
# specialArgs, then import this file.
{ ghostfx, ... }:
{
  home-manager.sharedModules = [ ghostfx.homeManagerModules.default ];

  home-manager.users.me = {
    programs.ghostty.enable = true;
    programs.ghostfx = {
      enable = true;
      shader = "northern-lights";
      preset = "subtle";
      quality = "eco";          # laptop-friendly
    };
  };

  # System-wide CLI (optional): `ghostfx list`, `ghostfx search`, previews...
  # environment.systemPackages = [ ghostfx.packages.x86_64-linux.default ];
}
