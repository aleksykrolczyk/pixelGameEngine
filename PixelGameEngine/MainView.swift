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

            engine.drawCircle(at: Point(20, 50), radius: 45, color: RED, fill: .filled)
            
        }
        .frame(width: 600, height: 600)
    }
}

#Preview {
    MainView()
}
