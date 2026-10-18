# Every shader pre-built with every built-in preset, plus legacy builds:
#   $out/share/ghostfx/shaders/<category>/<id>.glsl            (balanced)
#   $out/share/ghostfx/shaders/<category>/<id>.<preset>.glsl
#   $out/share/ghostfx/shaders/<category>/<id>.legacy.glsl     (Ghostty 1.2)
{ runCommand, ghostfx }:

runCommand "ghostfx-shaders-${ghostfx.version}" { nativeBuildInputs = [ ghostfx ]; } ''
  export HOME=$TMPDIR
  ghostfx build --all --presets --legacy --out $out/share/ghostfx/shaders
''
