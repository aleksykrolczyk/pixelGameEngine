//
//  ContentView.swift
//  PixelGameEngine
//
//  Created by Aleksy Krolczyk on 12/02/2024.
//

import SwiftUI

let RED: SIMD4<Float> = [1, 0, 0, 1]
let GREEN: SIMD4<Float> = [0, 1, 0, 1]
let BLUE: SIMD4<Float> = [0, 0, 1, 1]

struct MainView: View {
    var body: some View {
        PixelGameEngineView(pixelsOnScreen: (width: 100, height: 100), mode: .auto(fps: 60)) { engine in
            engine.clear()

            engine.drawTriangle(p1: Point(99, 99), p2: Point(50, 50), p3: Point(99, 50), color: RED, fill: .filled)
            engine.drawTriangle(p1: Point(30, 90), p2: Point(90, 20), p3: Point(10, 10), color: GREEN, fill: .filled)
            engine.drawTriangle(p1: Point(40, 10), p2: Point(10, 90), p3: Point(90, 10), color: BLUE, fill: .border)
        }
        .frame(width: 600, height: 600)
    }
}

#Preview {
    MainView()
}
