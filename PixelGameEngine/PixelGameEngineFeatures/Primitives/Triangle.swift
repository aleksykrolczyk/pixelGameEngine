//
//  Triangle.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 13/02/2024.
//

import Foundation


extension PixelGameEngine {
    
    fileprivate func getBoundsX(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, bounds: inout [Int]) {
        let dx = x2 - x1
        var dy = y2 - y1
        
        let yi = dy > 0 ? 1 : -1
        dy = abs(dy)
        
        var diff = 2 * dy - dx
        var y = y1
        
        for x in x1 ... x2 {
            bounds[y - y1] = x
            
            if diff > 0 {
                y += yi
                diff += 2 * (dy - dx)
            } else {
                diff += 2 * dy
            }
        }
    }
    
    fileprivate func getBoundsY(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, bounds: inout [Int]) {
        var dx = x2 - x1
        let dy = y2 - y1
        
        let xi = dx > 0 ? 1 : -1
        dx = abs(dx)
        
        var diff = 2 * dx - dy
        var x = x1
        
        for y in y1 ... y2 {
            
            bounds[y - y1] = x
            
            if diff > 0 {
                x += xi
                diff += 2 * (dx - dy)
            } else {
                diff += 2 * dx
            }
        }
    }
    
    
    fileprivate func drawLineSegment(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, bounds: inout [Int]) {
        if abs(y2 - y1) < abs(x2 - x1) {
            if x1 > x2 {
                getBoundsX(x2, y2, x1, y1, bounds: &bounds)
            } else {
                getBoundsX(x1, y1, x2, y2, bounds: &bounds)
            }
        } else {
            if y1 > y2 {
                getBoundsY(x2, y2, x1, y1, bounds: &bounds)
            } else {
                getBoundsY(x1, y1, x2, y2, bounds: &bounds)
            }
        }
    }
    
    
    fileprivate func fillBottomFlatTriangle(x1: Int, y1: Int, x2: Int, y2: Int, x3: Int, y3: Int, pixel: Pixel) {
        var bounds1: [Int] = .init(repeating: 0, count: y1 - y2 + 1)
        var bounds2: [Int] = .init(repeating: 0, count: y1 - y2 + 1)
        
        drawLineSegment(x1, y1, x2, y2, bounds: &bounds1)
        drawLineSegment(x1, y1, x3, y3, bounds: &bounds2)
        
        for y in 0 ... y1 - y2 {
            let minx = min(bounds1[y], bounds2[y])
            let maxx = max(bounds1[y], bounds2[y])
            for x in minx ... maxx {
                self[x, y2 + y] = pixel
            }
        }
        
    }

    fileprivate func fillTopFlatTriangle(x1: Int, y1: Int, x2: Int, y2: Int, x3: Int, y3: Int, pixel: Pixel) {
        var bounds1: [Int] = .init(repeating: 0, count: y2 - y1 + 1)
        var bounds2: [Int] = .init(repeating: 0, count: y2 - y1 + 1)
        
        drawLineSegment(x2, y2, x1, y1, bounds: &bounds1)
        drawLineSegment(x3, y3, x1, y1, bounds: &bounds2)
        
        for y in 0 ... y2 - y1 {
            let minx = min(bounds1[y], bounds2[y])
            let maxx = max(bounds1[y], bounds2[y])
            for x in minx ... maxx {
                self[x, y1 + y] = pixel
            }
        }
        
    }

    fileprivate func drawTriangleFilled(x1: Int, y1: Int, x2: Int, y2: Int, x3: Int, y3: Int, color: S4F) {
        var highx, highy, midx, midy, lowx, lowy: Int
        if y1 >= y2 && y1 >= y3 {
            if y2 >= y3 {
                (highx, highy, midx, midy, lowx, lowy) = (x1, y1, x2, y2, x3, y3)
            } else {
                (highx, highy, midx, midy, lowx, lowy) = (x1, y1, x3, y3, x2, y2)
            }
        } else if y2 >= y1 && y2 >= y3 {
            if y1 >= y3 {
                (highx, highy, midx, midy, lowx, lowy) = (x2, y2, x1, y1, x3, y3)
            } else {
                (highx, highy, midx, midy, lowx, lowy) = (x2, y2, x3, y3, x1, y1)
            }
        } else {
            if y1 >= y2 {
                (highx, highy, midx, midy, lowx, lowy) = (x3, y3, x1, y1, x2, y2)
            } else {
                (highx, highy, midx, midy, lowx, lowy) = (x3, y3, x2, y2, x1, y1)
            }
        }

        let dx = highx - lowx
        let dy = highy - lowy
        
        let nominator = dx * (midy - highy) + dy * highx
        let newx = Int(Float(nominator) / Float(dy))
        let newy = midy

        fillBottomFlatTriangle(x1: highx, y1: highy, x2: midx, y2: midy, x3: newx, y3: newy, pixel: color.toPixel)
        fillTopFlatTriangle(x1: lowx, y1: lowy, x2: midx, y2: midy, x3: newx, y3: newy, pixel: color.toPixel)
    }

    func drawTriangle(x1: Int, y1: Int, x2: Int, y2: Int, x3: Int, y3: Int, color: S4F, fill: Fill) {
        switch fill {
        case .border:
            drawLineSegment(x1, y1, x2, y2, color: color)
            drawLineSegment(x2, y2, x3, y3, color: color)
            drawLineSegment(x3, y3, x1, y1, color: color)
        case .filled:
            drawTriangleFilled(x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3, color: color)
            break
        }
    }

    func drawTriangle(p1: Point, p2: Point, p3: Point, color: S4F, fill: Fill) {
        drawTriangle(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, x3: p3.x, y3: p3.y, color: color, fill: fill)
    }
}
