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

    static func - (lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (lhs: Point, rhs: Int) -> Point {
        return Point(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func / (lhs: Point, rhs: Int) -> Point {
        return Point(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

typealias Size = Point

enum InputButton {
    case f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12
    case kParagraph, k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, kMinus, kEquals
    case kTab, kQ, kW, kE, kR, kT, kY, kU, kI, kO, kP, kLeftSquareBracket, kRightSquareBracket
    case kA, kS, kD, kF, kG, kH, kJ, kK, kL, kSemicolon, kApostrophe, kBackslash
    case kTilde, kZ, kX, kC, kV, kB, kN, kM, kComa, kDot, kSlash
    case kEscape, kSpace, kDelete, kEnter
    case kArrowLeft, kArrowRight, kArrowUp, kArrowDown

    case leftMouseButton, rightMouseButton, otherMouseButton

    // Modifier Keys
    
    case capslock, shift, function, control, option
    
    init(keyEventCode: UInt16) {
        self = switch keyEventCode {
        case 122: .f1
        case 120: .f2
        case 099: .f3
        case 118: .f4
        case 096: .f5
        case 097: .f6
        case 098: .f7
        case 100: .f8
        case 101: .f9
        case 109: .f10
        case 103: .f11
        case 111: .f12

        case 048: .kTab
        case 012: .kQ
        case 013: .kW
        case 014: .kE
        case 015: .kR
        case 017: .kT
        case 016: .kY
        case 032: .kU
        case 034: .kI
        case 031: .kO
        case 035: .kP
        case 033: .kLeftSquareBracket
        case 030: .kRightSquareBracket

        case 010: .kParagraph
        case 018: .k1
        case 019: .k2
        case 020: .k3
        case 021: .k4
        case 023: .k5
        case 022: .k6
        case 026: .k7
        case 028: .k8
        case 025: .k9
        case 029: .k0
        case 027: .kMinus
        case 024: .kEquals

        case 000: .kA
        case 001: .kS
        case 002: .kD
        case 003: .kF
        case 005: .kG
        case 004: .kH
        case 038: .kJ
        case 040: .kK
        case 037: .kL
        case 041: .kSemicolon
        case 039: .kApostrophe
        case 042: .kBackslash

        case 050: .kTilde
        case 006: .kZ
        case 007: .kX
        case 008: .kC
        case 009: .kV
        case 011: .kB
        case 045: .kN
        case 046: .kM
        case 043: .kComa
        case 047: .kDot
        case 044: .kSlash

        case 053: .kEscape
        case 049: .kSpace

        // These buttons return different code depending on whether FN key is down or not
        case 051, 117: .kDelete
        case 036, 076: .kEnter

        case 123, 115: .kArrowLeft
        case 126, 116: .kArrowUp
        case 124, 119: .kArrowRight
        case 125, 121: .kArrowDown

        default: fatalError("keycode \(keyEventCode) not recognized")
        }
    }
}
