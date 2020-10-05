//
//  MetalModule.swift
//  MetalColorRemove
//
//  Created by Yiqin Zhao on 10/4/20.
//

import Metal

class MetalComputeModule {
    let device: MTLDevice
    let commandBuffer: MTLCommandBuffer
    let commandEncoder: MTLComputeCommandEncoder
    
    var threadgroupCount: MTLSize
    var threadgroupSize: MTLSize

    init (kernelName: String) {
        
        self.device = MTLCreateSystemDefaultDevice()!

        let mtlLibrary: MTLLibrary? = self.device.makeDefaultLibrary()
        let addKernel: MTLFunction? = mtlLibrary?.makeFunction(name: kernelName)

        let pipeline: MTLComputePipelineState = try! device.makeComputePipelineState(function: addKernel!)

        let commandQueue: MTLCommandQueue = device.makeCommandQueue()!
        self.commandBuffer = commandQueue.makeCommandBuffer()!
        
        self.commandEncoder = self.commandBuffer.makeComputeCommandEncoder()!
        self.commandEncoder.setComputePipelineState(pipeline)
        
        self.threadgroupCount = MTLSize(width: 1, height: 1, depth: 1)
        self.threadgroupSize = MTLSize(width: 1, height: 1, depth: 1)
    }
    
    func setBuffer() { }

    subscript(gridSize: [Int], threadgroupSize: [Int]) -> Self {
        var gSize = [1, 1, 1]
        for i in 0..<min(gridSize.count, 3) { gSize[i] = gridSize[i] }
        
        self.threadgroupCount = MTLSize(width: gSize[0], height: gSize[1], depth: gSize[2])
        
        var tSize = [1, 1, 1]
        for i in 0..<min(threadgroupSize.count, 3) { tSize[i] = threadgroupSize[i] }
        self.threadgroupSize = MTLSize(width: tSize[0], height: tSize[1], depth: tSize[2])
        
        return self
    }
    
    subscript(gridSize: Int, threadgroupSize: Int) -> Self {
        self.threadgroupCount = MTLSize(width: gridSize, height: 1, depth: 1)
        self.threadgroupSize = MTLSize(width: threadgroupSize, height: 1, depth: 1)
        return self
    }
    
    subscript(gridSize: Int, threadgroupSize: [Int]) -> Self {
        self.threadgroupCount = MTLSize(width: gridSize, height: 1, depth: 1)
        
        var tSize = [1, 1, 1]
        for i in 0..<min(threadgroupSize.count, 3) { tSize[i] = threadgroupSize[i] }
        self.threadgroupSize = MTLSize(width: tSize[0], height: tSize[1], depth: tSize[2])
        
        return self
    }
    
    subscript(gridSize: [Int], threadgroupSize: Int) -> Self {
        var gSize = [1, 1, 1]
        for i in 0..<min(gridSize.count, 3) { gSize[i] = gridSize[i] }
        
        self.threadgroupCount = MTLSize(width: gSize[0], height: gSize[1], depth: gSize[2])
        self.threadgroupSize = MTLSize(width: threadgroupSize, height: 1, depth: 1)
        
        return self
    }
}
