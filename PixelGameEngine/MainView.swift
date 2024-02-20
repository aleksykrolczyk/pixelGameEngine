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
let WHITE: SIMD4<Float> = [1, 1, 1, 1]

struct MainView: View {
    @State var previousMousePos: Point? = nil

    var body: some View {
        // TODO: weird things happend if width != height
        PixelGameEngineView(pixelsOnScreen: (width: 512, height: 512), preferredFPS: 60, name: "TestApp") { engine, dt in
            print(dt)
            
            if let pos = engine.mousePosition, engine.isButtonClicked(.leftMouseButton) == true {
                if let previousPos = previousMousePos {
                    engine.drawLineSegment(from: previousPos, to: pos, color: WHITE)
                } else {
                    engine.drawPixel(at: pos, color: GREEN)
                }
                previousMousePos = pos
            } else {
                previousMousePos = nil
            }

            if engine.isButtonClicked(.kR) {
                engine.clear()
            }
        }
        .frame(width: 600, height: 600)
    }
}

//#Preview {
//    MainView()
//}
