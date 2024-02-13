//
//  Triangle.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 13/02/2024.
//

import Foundation

extension PixelGameEngine {
    
    func drawTriangle(x1: Int, y1: Int, x2: Int, y2: Int, x3: Int, y3: Int, color: S4F, fill: Fill) {
        switch fill {
            case .border:
                drawLineSegment(x1, y1, x2, y2, color: color)
                drawLineSegment(x2, y2, x3, y3, color: color)
                drawLineSegment(x3, y3, x1, y1, color: color)
            case .filled:
                // TODO:
                break
        }
    }
    
    func drawTriangle(p1: Point, p2: Point, p3: Point, color: S4F, fill: Fill) {
        drawTriangle(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, x3: p3.x, y3: p3.y, color: color, fill: fill)
    }
}
