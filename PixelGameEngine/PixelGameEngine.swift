//
//  PixelGameEngine.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 06/02/2024.
//

import Foundation
import MetalKit

enum Fill {
    case border, filled
}

typealias S4F = SIMD4<Float>

fileprivate extension S4F {
    var toPixel: Pixel {
        return Pixel(color: self)
    }
}

class PixelGameEngine {
    var frameBuffer: [Pixel]

    let height: Int
    let width: Int

    init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height

        self.frameBuffer = Array(repeating: Pixel(color: [0.0, 0.0, 0.0, 1.0]), count: width * height)
    }

    func isInBounds(p: Point) -> Bool {
        if p.x < 0 || p.x > self.width - 1 || p.y < 0 || p.y > self.height - 1 {
            return false
        }
        return true
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
}

extension PixelGameEngine {
    subscript(_ x: Int, _ y: Int) -> Pixel {
        get {
            frameBuffer[y * width + x]
        }
        set(newValue) {
            frameBuffer[y * width + x] = newValue
        }
    }

    subscript(p: Point) -> Pixel {
        get {
            frameBuffer[p.y * width + p.x]
        }
        set(newValue) {
            frameBuffer[p.y * width + p.x] = newValue
        }
    }
}
