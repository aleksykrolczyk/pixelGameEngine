//
//  Shaders.metal
//  Powderbox
//
//  Created by Aleksy Krolczyk on 23/01/2024.
//

#include <metal_stdlib>
#include "PixelGameEngine_Bridging_Header.h"

using namespace metal;


struct Constants {
    uint16_t targetPixelsHeight;
    uint16_t targetPixelsWidth;
};


kernel void clearScreen(texture2d < half, access::write > texture [[ texture(0)]], uint2 id [[ thread_position_in_grid ]]) {
    texture.write(half4(1), id);
}

kernel void drawPixels(
    device Pixel *pixels [[ buffer(0) ]],
    constant Constants &constants [[ buffer(1) ]],
    texture2d < half, access::write > texture [[ texture(0) ]],
    uint2 position [[ thread_position_in_grid ]]
) {
    uint width = texture.get_width();
    uint height = texture.get_height();

    if (position.x >= width || position.y >= height) {
        return;
    }

    uint x = floor((float)position.x * constants.targetPixelsWidth / width);
    uint y = floor((float)position.y * constants.targetPixelsHeight / height);

    Pixel px = pixels[y * constants.targetPixelsWidth + x];
    half4 color = half4(px.color.r, px.color.g, px.color.b, 1);
    texture.write(color, position);
}
