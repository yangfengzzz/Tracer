//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

kernel void blit(texture2d<float, access::write> out [[texture(0)]],
                 device float4* color [[buffer(0)]],
                 uint3 tpig [[ thread_position_in_grid ]],
                 uint3 gridSize [[threads_per_grid]]) {
    out.write(color[tpig.x + tpig.y * gridSize.x], tpig.xy);
}
