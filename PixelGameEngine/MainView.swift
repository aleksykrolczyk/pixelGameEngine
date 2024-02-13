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
        PixelGameEngineView(pixelsOnScreen: (width: 128, height: 128), mode: .auto(fps: 60)) { engine in
            engine.clear()
        }
        .frame(width: 600, height: 600)
    }
}

#Preview {
    MainView()
}
