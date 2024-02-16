//
//  GameScreen.swift
//  Sandbox
//
//  Created by Aleksy Krolczyk on 22/01/2024.
//

import MetalKit
import SwiftUI

enum RefreshMode {
    case auto(fps: Int)
}

struct PixelGameEngineView: NSViewRepresentable {
    private let engine: PixelGameEngine
    private let mode: RefreshMode

    private let onCreate: (() -> Void)?
    private let onUpdate: (PixelGameEngine) -> Void

    init(
        pixelsOnScreen: (width: Int, height: Int),
        mode: RefreshMode,
        onCreate: (() -> Void)? = nil,
        onUpdate: @escaping ((PixelGameEngine) -> Void)
    ) {
        self.engine = PixelGameEngine(pixelsOnScreen.width, pixelsOnScreen.height)
        self.mode = mode
        self.onCreate = onCreate
        self.onUpdate = onUpdate
    }

    func makeCoordinator() -> PixelViewCoordinator {
        return PixelViewCoordinator(self, engine: engine, onUpdate: onUpdate)
    }

    private func initMTKView(coordinator: MTKViewDelegate) -> MTKView {
        let mtkView = MTKView()

        mtkView.delegate = coordinator

        mtkView.isPaused = false

        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }

        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size

        switch mode {
        case let .auto(fps: fps):
            mtkView.enableSetNeedsDisplay = false
            mtkView.preferredFramesPerSecond = fps
        }

        return mtkView
    }

    private func setupMouseTracking(for mtkView: MTKView) {
        // TODO: tracking LMB and RMB
        let options: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        let trackingArea = NSTrackingArea(rect: .zero, options: options, owner: mtkView.delegate, userInfo: nil)
        mtkView.addTrackingArea(trackingArea)
    }

    func makeNSView(context: Context) -> some NSView {
        let mtkView = initMTKView(coordinator: context.coordinator)

        setupMouseTracking(for: mtkView)

        onCreate?()

        return mtkView
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {}
}

class PixelViewCoordinator: NSResponder, MTKViewDelegate {
    struct Constants {
        var targetPixelsWidth: UInt16 = 0
        var targetPixelsHeight: UInt16 = 0
    }

    var parent: PixelGameEngineView
    var engine: PixelGameEngine

    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!

    var clearScreen: MTLComputePipelineState
    var drawPixels: MTLComputePipelineState

    var constants: Constants

    var constantsBuffer: MTLBuffer?
    var pixelsBuffer: MTLBuffer?

    let onUpdate: (PixelGameEngine) -> Void

    init(_ parent: PixelGameEngineView, engine: PixelGameEngine, onUpdate: @escaping (PixelGameEngine) -> Void) {
        self.parent = parent
        self.engine = engine
        self.onUpdate = onUpdate

        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }

        guard let library = metalDevice.makeDefaultLibrary() else {
            fatalError("could not get default library")
        }

        self.metalCommandQueue = metalDevice.makeCommandQueue()
        self.clearScreen = try! metalDevice.makeComputePipelineState(function: library.makeFunction(name: "clearScreen")!)
        self.drawPixels = try! metalDevice.makeComputePipelineState(function: library.makeFunction(name: "drawPixels")!)

        self.constants = Constants(targetPixelsWidth: UInt16(engine.width), targetPixelsHeight: UInt16(engine.height))

        super.init()
    }

    required init?(
        coder: NSCoder) { fatalError("init(coder:) has not been implemented")
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        else {
            return
        }

        onUpdate(engine)

        pixelsBuffer = metalDevice.makeBuffer(bytes: engine.frameBuffer, length: MemoryLayout<SIMD4<Float>>.stride * engine.height * engine.width)!
        constantsBuffer = metalDevice.makeBuffer(bytes: &constants, length: MemoryLayout<Constants>.stride)!

        computeCommandEncoder.setComputePipelineState(clearScreen)
        computeCommandEncoder.setTexture(drawable.texture, index: 0)

        let width = clearScreen.threadExecutionWidth
        let height = clearScreen.maxTotalThreadsPerThreadgroup / width

        let threadsPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        let threadsPerThreadGroup = MTLSize(width: width, height: height, depth: 1)
        computeCommandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)

        computeCommandEncoder.setComputePipelineState(drawPixels)
        computeCommandEncoder.setBuffer(pixelsBuffer, offset: 0, index: 0)
        computeCommandEncoder.setBuffer(constantsBuffer, offset: 0, index: 1)

        let threadgroupsPerGrid = MTLSize(
            width: (drawable.texture.width + width - 1) / width,
            height: (drawable.texture.height + height - 1) / height,
            depth: 1
        )
        computeCommandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)

        computeCommandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    // MARK: Mouse handling

    override func mouseMoved(with event: NSEvent) {
        // There must be an easier way...
        let TITLE_HEIGHT: CGFloat = event.window?.hasTitleBar == true ? 28 : 0
        if let minSize = event.window?.minSize, let frame = event.window?.frame {
            let loc = event.locationInWindow

            let isWidthSet = minSize.width != 0
            let isHeightSet = minSize.height != TITLE_HEIGHT

            let pixelGameFrameWidth = isWidthSet ? min(minSize.width, frame.width) : frame.width
            let pixelGameFrameHeight = (isHeightSet ? min(minSize.height, frame.height) : frame.height) - TITLE_HEIGHT

            let leftRightColWidth = (frame.width - minSize.width) / 2
            let topBottomRowHeight = (frame.height - minSize.height) / 2

            let xInPixelGameFrame: Double = loc.x - leftRightColWidth
            let yInPixelGameFrame: Double = minSize.height + topBottomRowHeight - TITLE_HEIGHT - loc.y

            let p = Point(
                x: Int(xInPixelGameFrame / pixelGameFrameWidth * Double(engine.width)) + (isWidthSet ? 0 : engine.width / 2),
                y: Int(yInPixelGameFrame / pixelGameFrameHeight * Double(engine.height)) + (isHeightSet ? 0 : engine.height / 2)
            )
            engine.setMousePosition(p: p)
        }
    }

    override func mouseExited(with event: NSEvent) {
        engine.setMousePosition(p: nil)
    }
}
