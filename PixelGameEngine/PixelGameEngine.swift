//
//  PixelGameEngine.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 06/02/2024.
//

import Foundation
import MetalKit

internal typealias S4F = SIMD4<Float>

internal extension S4F {
    var toPixel: Pixel {
        return Pixel(color: self)
    }
}

class PixelGameEngine {
    var frameBuffer: [Pixel]

    let height: Int
    let width: Int

    private(set) var mousePosition: Point?

    init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height

        self.frameBuffer = Array(repeating: Pixel(color: [0.0, 0.0, 0.0, 1.0]), count: width * height)
    }

    func isInBounds(p: Point) -> Bool {
        return isInBounds(p.x, p.y)
    }

    func isInBounds(_ x: Int, _ y: Int) -> Bool {
        return x > -1 && x < self.width && y > -1 && y < self.height
    }

    func clear() {
        frameBuffer.withUnsafeMutableBytes { pointer in
            bzero(pointer.baseAddress, MemoryLayout<S4F>.stride * height * width)
        }
    }

    func drawPixel(color: S4F, at point: Point) {
        self[point] = Pixel(color: color)
    }

    func drawPixel(color: S4F, x: Int, y: Int) {
        self[x, y] = Pixel(color: color)
    }

    internal func setMousePosition(p: Point?) {
        self.mousePosition = p
    }
}

extension PixelGameEngine {
    subscript(_ x: Int, _ y: Int) -> Pixel {
        get {
            frameBuffer[y * width + x]
        }
        set(newValue) {
            if isInBounds(x, y) {
                frameBuffer[y * width + x] = newValue
            }
        }
    }

    subscript(p: Point) -> Pixel {
        get {
            frameBuffer[p.y * width + p.x]
        }
        set(newValue) {
            if isInBounds(p: p) {
                frameBuffer[p.y * width + p.x] = newValue
            }
        }
    }
}
