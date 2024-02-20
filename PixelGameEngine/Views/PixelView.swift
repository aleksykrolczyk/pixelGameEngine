//
//  GameScreen.swift
//  Sandbox
//
//  Created by Aleksy Krolczyk on 22/01/2024.
//

import MetalKit
import SwiftUI

typealias OnUpdateFunc = (PixelGameEngine, Double) -> Void

private class Metadata {
    var appName: String
    var lastFrameCount: UInt64

    init(appname: String) {
        self.appName = appname
        self.lastFrameCount = 0
    }
}

struct PixelGameEngineView: NSViewRepresentable {
    private let meta: Metadata

    private let engine: PixelGameEngine
    private let preferredFPS: Int

    private let onCreate: (() -> Void)?
    private let onUpdate: OnUpdateFunc

    private var lastFrameCount: UInt64 = 0

    init(
        pixelsOnScreen: (width: Int, height: Int),
        preferredFPS: Int,
        name appName: String = "Pixel Game Engine App",
        onCreate: (() -> Void)? = nil,
        onUpdate: @escaping OnUpdateFunc
    ) {
        self.engine = PixelGameEngine(pixelsOnScreen.width, pixelsOnScreen.height)
        self.preferredFPS = preferredFPS
        self.onCreate = onCreate
        self.onUpdate = onUpdate
        self.meta = Metadata(appname: appName)
    }

    func makeCoordinator() -> PixelViewCoordinator {
        return PixelViewCoordinator(self, engine: engine, onUpdate: onUpdate)
    }

    private func initMTKView(coordinator: MTKViewDelegate) -> MTKView {
        let mtkView = PixelGameEngineNSView()
        mtkView.engine = engine

        mtkView.delegate = coordinator

        mtkView.isPaused = false

        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }

        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size

        mtkView.enableSetNeedsDisplay = false
        mtkView.preferredFramesPerSecond = preferredFPS

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let newFramesCount = engine.elapsedFrames
            mtkView.window?.title = "\(meta.appName) (FPS: \(newFramesCount - meta.lastFrameCount))"
            meta.lastFrameCount = newFramesCount
        }

        return mtkView
    }

    private func setupMouseTracking(for mtkView: MTKView) {
        // TODO: tracking LMB and RMB
//        let options: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect, .enabledDuringMouseDrag]
        let options: NSTrackingArea.Options = [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved, .enabledDuringMouseDrag]
        let trackingArea = NSTrackingArea(rect: .zero, options: options, owner: mtkView, userInfo: nil)
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

    let onUpdate: OnUpdateFunc

    private var lastUpdateTimestamp: TimeInterval

    init(_ parent: PixelGameEngineView, engine: PixelGameEngine, onUpdate: @escaping OnUpdateFunc) {
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

        self.lastUpdateTimestamp = NSDate().timeIntervalSince1970

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

        let newUpdateTimestamp = NSDate().timeIntervalSince1970
        let diff = newUpdateTimestamp - lastUpdateTimestamp
        lastUpdateTimestamp = newUpdateTimestamp
        engine.increaseFrameCount()

        onUpdate(engine, diff)

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
}
