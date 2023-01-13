//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

class BasicSample: Renderer {
    let TWO_PI : Float = 6.28318530718
    let W = 512
    let H = 512
    let N = 64
    let MAX_STEP = 10
    let MAX_DISTANCE : Float = 2.0
    let EPSILON : Float = 1e-6
    
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
    
    func sample(_ x : Float, _ y : Float) -> Float {
        var sum: Float = 0.0
        for i in 0..<N {
            // float a = TWO_PI * rand() / RAND_MAX
            // float a = TWO_PI * i / N
            let a = TWO_PI * (Float(i) + Float.random(in: 0..<1)) / Float(N)
            sum += trace(x, y, cosf(a), sinf(a))
        }
        return sum / Float(N)
    }
    
    override func update(_ width: Int, _ height: Int) {
        for i in 0..<width {
            for j in 0..<height {
                let result = sample(Float(i) / Float(width), Float(j) / Float(height))
                buffer[i * height + j] = Color(x: result, y: result, z: result, w: 1.0)
            }
        }
    }
}

class SimpleView: GameViewController {
    override func createRenderer() -> Renderer? {
        BasicSample(metalKitView: mtkView)
    }
}
