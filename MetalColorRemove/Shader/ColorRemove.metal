//
//  ColorRemove.metal
//  MetalColorRemove
//
//  Created by Yiqin Zhao on 10/4/20.
//

#include <metal_stdlib>
using namespace metal;

constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

kernel void removeColor(texture2d<half, access::read> inTexture [[texture(0)]],
                        texture2d<half, access::write> outTexture [[texture(1)]],
                        uint2 gid [[thread_position_in_grid]])
{
    if((gid.x >= outTexture.get_width()) || (gid.y >= outTexture.get_height()))
    {
        return;
    }
    
    half4 inColor = inTexture.read(gid);
    half gray = dot(inColor.rgb, kRec709Luma);
    
    outTexture.write(half4(gray, gray, gray, 1), gid);
}
