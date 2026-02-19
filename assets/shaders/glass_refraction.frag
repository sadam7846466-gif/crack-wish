#version 460
#include <flutter/runtime_effect.glsl>

uniform sampler2D inputImage;
uniform vec2 uSize;
uniform float uBlur;
uniform float uRefraction;
uniform float uZoom;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 center = uv - 0.5;
  float r2 = dot(center, center);
  vec2 distorted = center * (1.0 + uRefraction * r2);
  vec2 baseUv = distorted / uZoom + 0.5;

  vec2 blurOffset = (uBlur * 0.002) * vec2(1.0, 1.0);
  vec4 col = texture(inputImage, baseUv) * 0.5;
  col += texture(inputImage, baseUv + blurOffset) * 0.25;
  col += texture(inputImage, baseUv - blurOffset) * 0.25;

  fragColor = col;
}
