//
//  Shaders.metal
//  Backdrop
//
//  Created by Alexander Smyshlaev on 12.07.26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 pixellate(float2 position, SwiftUI::Layer layer, float strength) {
    float min_strength = max(strength, 0.0001);
    float coord_x = min_strength * round(position.x / min_strength);
    float coord_y = min_strength * round(position.y / min_strength);
    return layer.sample(float2(coord_x, coord_y));
}

[[ stitchable ]] float2 wave(float2 position, float time, float intensity) {
    return position + float2 (sin(time + position.y / 20), sin(time + position.x / 20)) * intensity;
}
