//
//  Models.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import Foundation
import SwiftUI

enum SortDirection: String, CaseIterable, Identifiable {
    case ascending = "Ascending"
    case descending = "Descending"
    
    var id: String { rawValue }
}

enum SortAlgorithm: String, CaseIterable {
    case bubble = "Bubble Sort"
    case selection = "Selection Sort"
    case merge = "Merge Sort"
    case insertion = "Insertion Sort"
    case radix = "Radix Sort"
    case quick = "Quick Sort"
    case heap = "Heap Sort"
    case shell = "Shell Sort"
    case counting = "Counting Sort"
    case cocktail = "Cocktail Shaker Sort"
}

enum BarState {
    case unsorted
    case comparing
    case pivot      // For Quick Sort pivot element (green)
    case pointer    // For algorithm pointers/indices (light blue/cyan)
    case sorted
}

struct Bar: Identifiable, Equatable {
    let id: UUID
    let value: Int
    var state: BarState
    var offset: CGFloat = 0 // For horizontal animation
    
    init(value: Int, state: BarState = .unsorted) {
        self.id = UUID()
        self.value = value
        self.state = state
    }
    
    static func == (lhs: Bar, rhs: Bar) -> Bool {
        // Optimize: Only compare ID since each Bar has unique UUID
        // SwiftUI uses this for diffing - comparing all fields is expensive
        lhs.id == rhs.id
    }
}
