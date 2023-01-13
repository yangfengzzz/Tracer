//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal
import MetalKit
import simd

typealias Color = SIMD4<Float>

class Renderer: NSObject, MTKViewDelegate {
    public let device: MTLDevice
    let library: MTLLibrary
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLComputePipelineState
    var buffer: [Color] = []
    var bufferView: BufferView!
    
    init?(metalKitView: MTKView) {
        device = metalKitView.device!
        library = device.makeDefaultLibrary()!
        commandQueue = device.makeCommandQueue()!
        
        metalKitView.colorPixelFormat = MTLPixelFormat.rgba16Float
        metalKitView.sampleCount = 1
        metalKitView.framebufferOnly = false
        do {
            pipelineState = try device.makeComputePipelineState(function: library.makeFunction(name: "blit")!)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        super.init()
    }
    
    /// Per frame updates hare
    func draw(in view: MTKView) {
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            if let renderTarget = view.currentRenderPassDescriptor,
               let texture = renderTarget.colorAttachments[0].texture {
                update(texture.width, texture.height)
                bufferView.assign(with: buffer)
                
                if let encoder = commandBuffer.makeComputeCommandEncoder() {
                    encoder.setComputePipelineState(pipelineState)
                    encoder.setTexture(texture, index: 0)
                    encoder.setBuffer(bufferView.buffer, offset: 0, index: 0)
                    
                    let nWidth = min(texture.width, pipelineState.threadExecutionWidth)
                    let nHeight = min(texture.height, pipelineState.maxTotalThreadsPerThreadgroup / nWidth)
                    encoder.dispatchThreads(MTLSize(width: texture.width, height: texture.height, depth: 1),
                                            threadsPerThreadgroup: MTLSize(width: nWidth, height: nHeight, depth: 1))
                    encoder.endEncoding()
                }
            }
            
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            if let drawable = view.currentDrawable {
                commandBuffer.present(drawable)
            }
            commandBuffer.commit()
        }
    }

    /// Respond to drawable size or orientation changes here
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        buffer = [Color](repeating: Color(), count: Int(size.width * size.height))
        bufferView = BufferView(device: device, array: buffer)
    }
    
    /// update tracer buffer
    func update(_ width: Int, _ height: Int) {
        buffer = [Color](repeating: Color(1.0, 0, 0, 1.0), count: width * height)
    }
}
