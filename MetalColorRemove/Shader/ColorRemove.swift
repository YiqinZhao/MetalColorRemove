//
//  ColorRemove.swift
//  MetalColorRemove
//
//  Created by Yiqin Zhao on 10/4/20.
//

import Metal

class ColorRemoveModule : MetalComputeModule {
    init() {
        super.init(kernelName: "removeColor")
    }
    
    func callAsFunction(inTexture: MTLTexture, outTexture: MTLTexture) {
        
        self.commandEncoder.setTexture(inTexture, index: 0)
        self.commandEncoder.setTexture(outTexture, index: 1)

        self.commandEncoder.dispatchThreadgroups(self.threadgroupCount, threadsPerThreadgroup: self.threadgroupSize)

        self.commandEncoder.endEncoding()
        
        let blitEncoder = self.commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.synchronize(resource: outTexture)
        blitEncoder.endEncoding()
        
        self.commandBuffer.commit()
        self.commandBuffer.waitUntilCompleted()
    }
}
