//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import MetalKit

class BasicSample: Renderer {
    let TWO_PI : Float = 6.28318530718
    let MAX_STEP = 10
    let MAX_DISTANCE : Float = 2.0
    let EPSILON : Float = 1e-6
    
    var currentIndex: Int = 0
    var N = 32
    
    func circleSDF(_ x : Float, _ y : Float, _ cx : Float, _ cy : Float, _ r : Float)->Float {
        let ux = x - cx, uy = y - cy
        return sqrt(ux * ux + uy * uy) - r
    }
    
    func trace(_ ox : Float, _ oy : Float, _ dx : Float, _ dy : Float) -> Float {
        var t : Float = 0.0
        var i = 0
        while i < MAX_STEP && t < MAX_DISTANCE {
            let sd = circleSDF(ox + dx * t, oy + dy * t, 0.5, 0.5, 0.1)
            if (sd < EPSILON) {
                return 2.0
            }
            t += sd
            
            i = i + 1
        }
        return 0.0
    }
    
    func sample(_ x : Float, _ y : Float) -> Color {
        // let a = TWO_PI * Float.random(in: 0..<1)
        // let a = TWO_PI * Float(i) / Float(N)
        let a = TWO_PI * (Float(currentIndex) + Float.random(in: 0..<1)) / Float(N)
        let gray = trace(x, y, cosf(a), sinf(a))
        return Color(x: gray, y: gray, z: gray, w: 1)
    }
    
    override func update(_ width: Int, _ height: Int) {
        DispatchQueue.concurrentPerform(iterations: width * height) { (index:Int) in
            let color = sample(Float(index % width) / Float(width), Float(index / width) / Float(height))
            buffer[index] *= Float(currentIndex)
            buffer[index] += color
            buffer[index] /= Float(currentIndex + 1)
        }
        
        currentIndex = currentIndex + 1
        if currentIndex >= N {
            currentIndex = 0
            shouldUpdate = false
        }
    }
    
    public override func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        super.mtkView(view, drawableSizeWillChange: size)
        currentIndex = 0
    }
}

class SimpleView: GameViewController {
    override func createRenderer() -> Renderer? {
        BasicSample(metalKitView: mtkView)
    }
}
