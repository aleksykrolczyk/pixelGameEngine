//
//  Rectangle.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 13/02/2024.
//

import Foundation

extension PixelGameEngine {
    func drawRectangle(at p: Point, size s: Size, color: S4F, fill: Fill) {
        drawRectangle(x: p.x, y: p.y, size: s, color: color, fill: fill)
    }

    func drawRectangle(x: Int, y: Int, size s: Size, color: S4F, fill: Fill) {
        switch fill {
        case .border:
            drawLineSegment(x + 000, y + 000, x + s.x, y + 000, color: color)
            drawLineSegment(x + s.x, y + 000, x + s.x, y + s.y, color: color)
            drawLineSegment(x + s.x, y + s.y, x + 000, y + s.y, color: color)
            drawLineSegment(x + 000, y + s.y, x + 000, y + 000, color: color)
        case .filled:
            let pixel = Pixel(color: color)
            for y in y ... y + s.y {
                for x in x ... x + s.x {
                    self[x, y] = pixel
                }
            }
        }
    }
}
