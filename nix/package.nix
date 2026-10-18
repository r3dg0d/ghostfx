{ lib
, python3Packages
, glslang
, spirv-cross
, makeWrapper
, src
}:

python3Packages.buildPythonApplication {
  pname = "ghostfx";
  version = lib.fileContents "${src}/VERSION";
  pyproject = true;
  inherit src;

  build-system = [ python3Packages.hatchling ];

  nativeBuildInputs = [ makeWrapper ];

  # glslang/spirv-cross power `ghostfx validate` and install-time checks.
  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ glslang spirv-cross ]}"
  ];

  pythonImportsCheck = [ "ghostfx" ];

  meta = {
    description = "Animated GLSL shaders and a safe installer CLI for the Ghostty terminal";
    homepage = "https://github.com/r3dg0d/ghostfx";
    license = lib.licenses.mit;
    mainProgram = "ghostfx";
    platforms = lib.platforms.unix;
  };
}
