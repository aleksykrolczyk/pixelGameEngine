//
//  PixelGameEngineNSView.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 19/02/2024.
//

import Foundation
import MetalKit

internal class PixelGameEngineNSView: MTKView {
    var engine: PixelGameEngine?
}

// MARK: Mouse movement

extension PixelGameEngineNSView {
    private func handleMouseMoved(with event: NSEvent) {
        guard let engine = self.engine else { return }

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

    override func mouseMoved(with event: NSEvent) {
        handleMouseMoved(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        handleMouseMoved(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        engine?.setMousePosition(p: nil)
    }
}

// MARK: Keystrokes and mouse buttons clicks

extension PixelGameEngineNSView {
    override var acceptsFirstResponder: Bool {
        true
    }

    override func keyUp(with event: NSEvent) {
        if let button = InputButton(keyEventCode: event.keyCode) {
            engine?.unsetButtonClicked(button)
        }
    }

    override func keyDown(with event: NSEvent) {
        // If button is clicked with command, we don't receive keyUp, so just ignore it
        if event.modifierFlags.contains(.command) {
            return
        }
        print(event.keyCode, InputButton(keyEventCode: event.keyCode))
        if let button = InputButton(keyEventCode: event.keyCode) {
            engine?.setButtonClicked(button)
        }
    }

    override func flagsChanged(with event: NSEvent) {
        // TODO: Modifier keys
        super.flagsChanged(with: event)
    }

    override func mouseDown(with event: NSEvent) {
        engine?.setButtonClicked(.leftMouseButton)
    }

    override func mouseUp(with event: NSEvent) {
        engine?.unsetButtonClicked(.leftMouseButton)
    }

    override func rightMouseDown(with event: NSEvent) {
        engine?.setButtonClicked(.rightMouseButton)
    }

    override func rightMouseUp(with event: NSEvent) {
        engine?.unsetButtonClicked(.rightMouseButton)
    }

    override func otherMouseDown(with event: NSEvent) {
        engine?.setButtonClicked(.otherMouseButton)
    }

    override func otherMouseUp(with event: NSEvent) {
        engine?.unsetButtonClicked(.otherMouseButton)
    }
}
