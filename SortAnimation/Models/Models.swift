//
//  Models.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import Foundation
import SwiftUI

/// The direction in which to sort elements.
///
/// Use this enum to specify whether sorting should arrange elements from smallest to largest
/// or largest to smallest.
enum SortDirection: String, CaseIterable, Identifiable {
    /// Sort elements from smallest to largest
    case ascending = "Ascending"
    
    /// Sort elements from largest to smallest
    case descending = "Descending"
    
    var id: String { rawValue }
}

/// Available sorting algorithms in the visualizer.
///
/// Each case represents a different sorting algorithm with unique characteristics:
/// - Comparison-based sorts: bubble, selection, insertion, merge, quick, heap, shell, cocktail, gnome, comb, cycle, tim
/// - Non-comparison sorts: counting, radix
enum SortAlgorithm: String, CaseIterable {
    /// Bubble Sort - O(n²) comparison sort that repeatedly steps through the list
    case bubble = "Bubble Sort"
    
    /// Selection Sort - O(n²) comparison sort that divides input into sorted and unsorted regions
    case selection = "Selection Sort"
    
    /// Merge Sort - O(n log n) divide-and-conquer algorithm
    case merge = "Merge Sort"
    
    /// Insertion Sort - O(n²) sort that builds final sorted array one item at a time
    case insertion = "Insertion Sort"
    
    /// Radix Sort - O(nk) non-comparison integer sort using digit-by-digit sorting
    case radix = "Radix Sort"
    
    /// Quick Sort - O(n log n) divide-and-conquer algorithm using pivot partitioning
    case quick = "Quick Sort"
    
    /// Heap Sort - O(n log n) comparison sort using binary heap data structure
    case heap = "Heap Sort"
    
    /// Shell Sort - O(n log n) generalization of insertion sort using gap sequences
    case shell = "Shell Sort"
    
    /// Counting Sort - O(n+k) non-comparison integer sort for small range of keys
    case counting = "Counting Sort"
    
    /// Cocktail Shaker Sort - O(n²) bidirectional bubble sort variant
    case cocktail = "Cocktail Shaker Sort"
    
    /// Gnome Sort - O(n²) simple comparison sort similar to insertion sort
    case gnome = "Gnome Sort"
    
    /// Comb Sort - O(n log n) improved bubble sort using gap sequences
    case comb = "Comb Sort"
    
    /// Cycle Sort - O(n²) in-place sort minimizing writes to memory
    case cycle = "Cycle Sort"
    
    /// Tim Sort - O(n log n) hybrid stable sort combining merge and insertion sort
    case tim = "Tim Sort"
}

/// Visual state of a bar during sorting operations.
///
/// The state determines the bar's color during visualization:
/// - `unsorted`: White (default)
/// - `comparing`: Red (elements being compared)
/// - `pivot`: Green (pivot element in Quick Sort)
/// - `pointer`: Cyan (algorithm pointer/index)
/// - `sorted`: Green (confirmed in final position)
enum BarState {
    /// Element not yet processed
    case unsorted
    
    /// Element currently being compared
    case comparing
    
    /// Pivot element in partition-based sorts (Quick Sort)
    case pivot
    
    /// Algorithm pointer or index marker
    case pointer
    
    /// Element confirmed in its final sorted position
    case sorted
}

/// A visual representation of a sortable element.
///
/// Each bar has a unique identifier, integer value for sorting, visual state for coloring,
/// and offset for smooth horizontal swap animations.
struct Bar: Identifiable, Equatable {
    /// Unique identifier for SwiftUI list tracking
    let id: UUID
    
    /// The numeric value this bar represents (determines height)
    let value: Int
    
    /// Current visual state (affects bar color)
    var state: BarState
    
    /// Horizontal offset for smooth swap animations
    var offset: CGFloat = 0
    
    /// Creates a new bar with the specified value and state.
    ///
    /// - Parameters:
    ///   - value: The numeric value (1 to numberOfElements)
    ///   - state: Initial visual state (defaults to unsorted)
    init(value: Int, state: BarState = .unsorted) {
        self.id = UUID()
        self.value = value
        self.state = state
    }
    
    /// Compares two bars for equality based on their unique identifier.
    ///
    /// - Note: This optimization compares only IDs, not all properties, improving SwiftUI diffing performance.
    ///   Each bar has a unique UUID, so ID comparison is sufficient for identity.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side bar
    ///   - rhs: The right-hand side bar
    /// - Returns: `true` if both bars have the same ID
    static func == (lhs: Bar, rhs: Bar) -> Bool {
        lhs.id == rhs.id && lhs.state == rhs.state && lhs.offset == rhs.offset
    }
}
