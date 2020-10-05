//
//  Helpers.swift
//  MetalColorRemove
//
//  Created by Yiqin Zhao on 10/4/20.
//

import Metal

func getCGImage(from mtlTexture: MTLTexture, width: Int, height: Int) -> CGImage? {
    var data = [UInt8]()
    data.reserveCapacity(4 * width * height)
    
    mtlTexture.getBytes(&data,
                        bytesPerRow: 4 * width,
                        from: MTLRegionMake2D(0, 0, width, height),
                        mipmapLevel: 0)

    let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    let context = CGContext(data: &data,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: 4 * width,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo.rawValue)

    return context?.makeImage()
}
