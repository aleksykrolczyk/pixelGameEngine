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
        PixelGameEngineView(
            pixelsOnScreen: (width: 256, height: 256),
            preferredFPS: 60,
            name: "Preview",
            onCreate: { engine in
                drawBackground(with: engine)
            },
            onUpdate: { engine, _ in

                if let pos = engine.mousePosition, engine.isButtonClicked(.leftMouseButton) == true {
                    if let previousPos = previousMousePos {
                        engine.drawLineSegment(from: previousPos, to: pos, color: WHITE)
                    } else {
                        engine.drawPixel(at: pos, color: WHITE)
                    }
                    previousMousePos = pos
                } else {
                    previousMousePos = nil
                }
                if engine.isButtonClicked(.kR) {
                    engine.clear()
                    drawBackground(with: engine)
                }

            })
            .frame(width: 600, height: 600)
    }

    func drawBackground(with engine: PixelGameEngine) {
        engine.drawRectangle(at: Point(5, 200), size: Size(225, 30), color: BLUE, fill: .filled)
        engine.drawRectangle(at: Point(200, 30), size: Size(45, 230), color: GREEN, fill: .border)

        engine.drawCircle(50, 175, radius: 30, color: RED, fill: .filled)
        engine.drawCircle(67, 170, radius: 20, color: GREEN, fill: .border)
        engine.drawText("hello there", at: Point(10, 20))
    }
}

// #Preview {
//    MainView()
// }
