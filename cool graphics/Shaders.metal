//
//  Shaders.metal
//  cool graphics
//
//  Created by Sima Nerush on 12/7/22.
//

#include <metal_stdlib>
using namespace metal;

// returns final position of the vertex
vertex float4 basic_vertex(const device packed_float3* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
  return float4(vertex_array[vid], 1.0);
}

// make fragment white
fragment half4 basic_fragment() {
  return half4(1.0);
}
