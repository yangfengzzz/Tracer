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
    let commandQueue: MTLCommandQueue
    var buffer: [Color] = []
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        metalKitView.colorPixelFormat = MTLPixelFormat.rgba32Float
        metalKitView.sampleCount = 1
        
        super.init()
    }
    
    /// Per frame updates hare
    func draw(in view: MTKView) {
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            if let renderTarget = view.currentRenderPassDescriptor,
               let texture = renderTarget.colorAttachments[0].texture {
                update(texture.width, texture.height)
                texture.replace(region: MTLRegionMake2D(0, 0, texture.width, texture.height), mipmapLevel: 0,
                                withBytes: buffer, bytesPerRow: MemoryLayout<Color>.stride * texture.width)
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
    }
    
    /// update tracer buffer
    func update(_ width: Int, _ height: Int) {
        buffer = [Color](repeating: Color(0.5, 0, 0, 1), count: width * height)
    }
}
