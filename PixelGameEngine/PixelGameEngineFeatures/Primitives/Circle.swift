//
//  Circle.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 13/02/2024.
//

import Foundation

extension PixelGameEngine {
    fileprivate func drawCirclePoint(_ xc: Int, _ yc: Int, _ x: Int, _ y: Int, pixel: Pixel) {
        self[xc + x, yc + y] = pixel
        self[xc + x, yc - y] = pixel
        self[xc - x, yc + y] = pixel
        self[xc - x, yc - y] = pixel

        self[xc + y, yc + x] = pixel
        self[xc + y, yc - x] = pixel
        self[xc - y, yc + x] = pixel
        self[xc - y, yc - x] = pixel
    }

    fileprivate func drawCircleLine(_ xc: Int, _ yc: Int, _ x: Int, _ y: Int, pixel: Pixel) {
        for xi in xc - x ... xc + x {
            self[xi, yc + y] = pixel
            self[xi, yc - y] = pixel
        }

        for xi in xc - y ... xc + y {
            self[xi, yc + x] = pixel
            self[xi, yc - x] = pixel
        }
    }

    fileprivate func drawCircleBorder(_ xc: Int, _ yc: Int, radius: Int, pixel: Pixel) {
        var p = 3 - 2 * radius

        var x = 0
        var y = radius

        while x <= y {
            drawCirclePoint(xc, yc, x, y, pixel: pixel)
            x += 1
            if p < 0 {
                p += 4 * x + 6
            } else {
                p += 4 * (x - y) + 10
                y -= 1
            }
        }
    }

    fileprivate func drawCircleFilled(_ xc: Int, _ yc: Int, radius: Int, pixel: Pixel) {
        var p = 3 - 2 * radius

        var x = 0
        var y = radius

        while x <= y {
            drawCircleLine(xc, yc, x, y, pixel: pixel)
            x += 1
            if p < 0 {
                p += 4 * x + 6
            } else {
                p += 4 * (x - y) + 10
                y -= 1
            }
        }
    }

    func drawCircle(_ x: Int, _ y: Int, radius: Int, color: S4F, fill: Fill) {
        let pixel = Pixel(color: color)
        switch fill {
        case .border:
            drawCircleBorder(x, y, radius: radius, pixel: pixel)
        case .filled:
            drawCircleFilled(x, y, radius: radius, pixel: pixel)
        }
    }

    func drawCircle(at center: Point, radius: Int, color: S4F, fill: Fill) {
        drawCircle(center.x, center.y, radius: radius, color: color, fill: fill)
    }
}
