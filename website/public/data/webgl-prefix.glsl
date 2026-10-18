#version 300 es
// GhostFX browser preview prefix (WebGL2 / GLSL ES 3.00).
// Mirrors the Ghostty 1.3 uniform set as plain uniforms so the same shader
// body compiles in the gallery. Previews are approximations of Ghostty.
precision highp float;
precision highp int;
precision highp sampler2D;

uniform vec3  iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform int   iFrame;
uniform vec4  iMouse;
uniform vec4  iDate;
uniform vec4  iCurrentCursor;
uniform vec4  iPreviousCursor;
uniform vec4  iCurrentCursorColor;
uniform vec4  iPreviousCursorColor;
uniform int   iCurrentCursorStyle;
uniform int   iPreviousCursorStyle;
uniform int   iCursorVisible;
uniform float iTimeCursorChange;
uniform float iTimeFocus;
uniform int   iFocus;
uniform vec3  iBackgroundColor;
uniform vec3  iForegroundColor;
uniform vec3  iCursorColor;
uniform vec3  iCursorText;
uniform vec3  iSelectionForegroundColor;
uniform vec3  iSelectionBackgroundColor;
uniform sampler2D iChannel0;

#define CURSORSTYLE_BLOCK        0
#define CURSORSTYLE_BLOCK_HOLLOW 1
#define CURSORSTYLE_BAR          2
#define CURSORSTYLE_UNDERLINE    3
#define CURSORSTYLE_LOCK         4

out vec4 _fragColor;
#define texture2D texture

void mainImage(out vec4 fragColor, in vec2 fragCoord);
void main() { mainImage(_fragColor, gl_FragCoord.xy); }
