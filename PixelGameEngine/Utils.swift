//
//  Utils.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 16/02/2024.
//

import Foundation

internal func clamp<T: Comparable>(_ x: T, _ minimum: T, maximum: T) -> T {
    return x > maximum ? maximum : x < minimum ? minimum : x
    
}
