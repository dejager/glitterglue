#include <metal_stdlib>
using namespace metal;

#define numberOfLayers 16.0
#define iterations 23

float4 texture(float3 p, float time) {
  float t = time + 78.0;
  float4 o = float4(p.xyz, 3.0 * sin(t * 0.1));
  float4 dec = float4 (1.0, 0.9, 0.1, 0.15) + float4(0.06 * cos(t * 0.1), 0,0, 0.14 * cos(t * 0.23));
  for (int i=0 ; i++ < iterations;) {
    o.xzyw = abs(o/dot(o,o)- dec);
  }
  return o;
}


kernel void glitterIsMyFavoriteColor(texture2d<float, access::write> o[[texture(0)]],
                                     constant float &time [[buffer(0)]],
                                     constant float &frame [[buffer(1)]],
                                     constant float2 *touchEvent [[buffer(2)]],
                                     constant int &numberOfTouches [[buffer(3)]],
                                     ushort2 gid [[thread_position_in_grid]]) {

  int width = o.get_width();
  int height = o.get_height();
  float2 res = float2(width, height);
  float2 p = float2(gid.xy);
  float2 uv = (p.xy - res.xy * 0.5) / res.y;

  float3 color = float3(0);
    float t= time * 0.3;

  for(float i=0.; i<=1.; i+=1.0 / numberOfLayers) {
    float depth = fract(i + t);
    float scale = mix(5.0, 0.5, depth);
    float fade = depth * smoothstep(1.0, 0.9, depth);
    color += texture(float3(uv * scale, i * 4.0), time).xyz * fade;
  }

  color /= numberOfLayers;
  color *= float3(2, 1.0, 2.0);
  color = pow(color, float3(0.5));

  o.write(float4(color, 1), gid);

//  int width = o.get_width();
//  int height = -o.get_height();
//  float2 res = float2(width, height);
//
//  float2 uv = float2(gid.xy) / res.xy;
//  uv.x -= 0.5;
//  uv.y += 1.0;
//  uv.x *= res.x / res.y;
//
//  float4 color = float4(render(uv, time), 1.0);
//  o.write(color, gid);
}
