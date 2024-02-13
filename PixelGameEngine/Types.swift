//
//  Auxiliary.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 12/02/2024.
//

import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    init(from p: CGPoint) {
        self.x = Int(p.x)
        self.y = Int(p.y)
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func * (lhs: Point, rhs: Int) -> Point {
        return Point(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func / (lhs: Point, rhs: Int) -> Point {
        return Point(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

typealias Size = Point
