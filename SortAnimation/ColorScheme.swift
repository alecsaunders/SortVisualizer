//
//  ColorScheme.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/18/26.
//

import SwiftUI

enum ColorSchemeType: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case educational = "Educational"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .classic:
            return "White/Red/White (Sound of Sorting style)"
        case .educational:
            return "Blue/Red/Green (distinct states)"
        case .custom:
            return "Choose your own colors"
        }
    }
}

struct ColorSchemeColors: Equatable, Codable {
    var unsorted: CodableColor
    var comparing: CodableColor
    var sorted: CodableColor
    
    static let classic = ColorSchemeColors(
        unsorted: CodableColor(.white),
        comparing: CodableColor(.red),
        sorted: CodableColor(.white)
    )
    
    static let educational = ColorSchemeColors(
        unsorted: CodableColor(.blue),
        comparing: CodableColor(.red),
        sorted: CodableColor(.green)
    )
    
    func color(for state: BarState) -> Color {
        switch state {
        case .unsorted:
            return unsorted.color
        case .comparing:
            return comparing.color
        case .sorted:
            return sorted.color
        }
    }
}

// Wrapper to make Color Codable for UserDefaults
struct CodableColor: Equatable, Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(_ color: Color) {
        // Convert SwiftUI Color to NSColor to extract components
        let nsColor = NSColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        nsColor.usingColorSpace(.deviceRGB)?.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
