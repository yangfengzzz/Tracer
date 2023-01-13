//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {
    var mtkView: MTKView!
    var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }
        
        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        mtkView.device = defaultDevice
        self.mtkView = mtkView
        
        if let renderer = createRenderer() {
            mtkView.delegate = renderer
            renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
            self.renderer = renderer
        }
    }
    
    func createRenderer() -> Renderer? {
        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return nil
        }
        return newRenderer
    }
}
