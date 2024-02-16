//
//  Lines.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 13/02/2024.
//

import Foundation

extension PixelGameEngine {
    fileprivate func drawLineX(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, pixel: Pixel) {
        let dx = x2 - x1
        var dy = y2 - y1

        let yi = dy > 0 ? 1 : -1
        dy = abs(dy)

        var diff = 2 * dy - dx
        var y = y1

        for x in x1 ... x2 {
            self[x, y] = pixel
            if diff > 0 {
                y += yi
                diff += 2 * (dy - dx)
            } else {
                diff += 2 * dy
            }
        }
    }

    fileprivate func drawLineY(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, pixel: Pixel) {
        var dx = x2 - x1
        let dy = y2 - y1

        let xi = dx > 0 ? 1 : -1
        dx = abs(dx)

        var diff = 2 * dx - dy
        var x = x1

        for y in y1 ... y2 {
            self[x, y] = pixel
            if diff > 0 {
                x += xi
                diff += 2 * (dx - dy)
            } else {
                diff += 2 * dx
            }
        }
    }

    func drawLineSegment(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, color: S4F) {
        let dx = x2 - x1
        let dy = y2 - y1

        let pixel = Pixel(color: color)

        if dx == 0 {
            for y in min(y1, y2) ... max(y1, y2) {
                self[x1, y] = pixel
            }
            return
        }

        if dy == 0 {
            for x in min(x1, x2) ... max(x1, x2) {
                self[x, y1] = pixel
            }
            return
        }

        // Use Bresenham's Line Algorithm
        if abs(y2 - y1) < abs(x2 - x1) {
            if x1 > x2 {
                drawLineX(x2, y2, x1, y1, pixel: pixel)
            } else {
                drawLineX(x1, y1, x2, y2, pixel: pixel)
            }
        } else {
            if y1 > y2 {
                drawLineY(x2, y2, x1, y1, pixel: pixel)
            } else {
                drawLineY(x1, y1, x2, y2, pixel: pixel)
            }
        }
    }

    func drawLineSegment(from p1: Point, to p2: Point, color: S4F) {
        drawLineSegment(p1.x, p1.y, p2.x, p2.y, color: color)
    }
}
