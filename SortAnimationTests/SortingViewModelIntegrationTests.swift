//
//  SortingViewModelIntegrationTests.swift
//  SortAnimationTests
//
//  Integration tests for SortingViewModel including visualization and async operations.
//

import Testing
@testable import SortAnimation

@MainActor
struct SortingViewModelIntegrationTests {
    
    // MARK: - Model Tests
    
    @Test func barEquality() {
        let bar1 = Bar(value: 5, state: .unsorted)
        let bar2 = Bar(value: 10, state: .comparing)
        let bar3 = bar1 // Same instance
        
        // Bars are equal only if they have the same ID
        #expect(bar1 == bar3)
        #expect(bar1 != bar2)
    }
    
    @Test func barStateTransitions() {
        var bar = Bar(value: 5, state: .unsorted)
        #expect(bar.state == .unsorted)
        
        bar.state = .comparing
        #expect(bar.state == .comparing)
        
        bar.state = .sorted
        #expect(bar.state == .sorted)
        
        bar.state = .pivot
        #expect(bar.state == .pivot)
        
        bar.state = .pointer
        #expect(bar.state == .pointer)
    }
    
    @Test func sortDirectionCases() {
        #expect(SortDirection.ascending.rawValue == "Ascending")
        #expect(SortDirection.descending.rawValue == "Descending")
        #expect(SortDirection.allCases.count == 2)
    }
    
    @Test func sortAlgorithmCases() {
        let algorithms = SortAlgorithm.allCases
        #expect(algorithms.count == 14)
        
        let expectedNames = [
            "Bubble Sort", "Selection Sort", "Merge Sort", "Insertion Sort",
            "Radix Sort", "Quick Sort", "Heap Sort", "Shell Sort",
            "Counting Sort", "Cocktail Shaker Sort", "Gnome Sort", "Comb Sort",
            "Cycle Sort", "Tim Sort"
        ]
        
        for (algorithm, name) in zip(algorithms, expectedNames) {
            #expect(algorithm.rawValue == name)
        }
    }
    
    // MARK: - ViewModel Initialization Tests
    
    @Test func viewModelInitialization() async {
        let viewModel = SortingViewModel()
        
        #expect(viewModel.bars.count == 100) // Default numberOfElements
        #expect(viewModel.selectedAlgorithm == .bubble)
        #expect(viewModel.sortDirection == .ascending)
        #expect(viewModel.speed == 10)
        #expect(viewModel.numberOfElements == 100)
        #expect(viewModel.isSorting == false)
        #expect(viewModel.isPaused == false)
    }
    
    @Test func resetFunctionality() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 50
        
        viewModel.reset()
        
        #expect(viewModel.bars.count == 50)
        #expect(viewModel.isSorting == false)
        #expect(viewModel.isPaused == false)
        #expect(viewModel.comparisonCount == 0)
        #expect(viewModel.swapCount == 0)
        #expect(viewModel.arrayAccessCount == 0)
    }
    
    // MARK: - Sorting Algorithm Correctness Tests
    
    @Test func bubbleSortAscending() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 20
        viewModel.selectedAlgorithm = .bubble
        viewModel.sortDirection = .ascending
        viewModel.speed = 0 // Fast for testing
        
        viewModel.reset()
        viewModel.startSort()
        
        // Wait for sort to complete
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func bubbleSortDescending() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 20
        viewModel.selectedAlgorithm = .bubble
        viewModel.sortDirection = .descending
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .descending))
    }
    
    @Test func selectionSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 20
        viewModel.selectedAlgorithm = .selection
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func insertionSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 20
        viewModel.selectedAlgorithm = .insertion
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func mergeSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 30
        viewModel.selectedAlgorithm = .merge
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func quickSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 30
        viewModel.selectedAlgorithm = .quick
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func heapSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 30
        viewModel.selectedAlgorithm = .heap
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func shellSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 30
        viewModel.selectedAlgorithm = .shell
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func countingSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 30
        viewModel.selectedAlgorithm = .counting
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func radixSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 30
        viewModel.selectedAlgorithm = .radix
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func cocktailSortCorrectness() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 20
        viewModel.selectedAlgorithm = .cocktail
        viewModel.speed = 0
        
        viewModel.reset()
        viewModel.startSort()
        
        try? await Task.sleep(for: .seconds(2))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    // MARK: - Statistics Tests
    
    @Test func statisticsTracking() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 10
        viewModel.selectedAlgorithm = .bubble
        viewModel.speed = 0
        
        viewModel.reset()
        #expect(viewModel.comparisonCount == 0)
        #expect(viewModel.swapCount == 0)
        
        viewModel.startSort()
        try? await Task.sleep(for: .seconds(1))
        
        // After sorting, stats should be non-zero
        #expect(viewModel.comparisonCount > 0)
        // Note: swapCount might be 0 if already sorted
    }
    
    // MARK: - Pause/Resume Tests
    
    @Test func pauseResumeFunctionality() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 50
        viewModel.selectedAlgorithm = .bubble
        viewModel.speed = 10
        
        viewModel.reset()
        viewModel.startSort()
        
        #expect(viewModel.isSorting == true)
        #expect(viewModel.isPaused == false)
        
        viewModel.togglePause()
        #expect(viewModel.isPaused == true)
        
        viewModel.togglePause()
        #expect(viewModel.isPaused == false)
    }
    
    // MARK: - Color Scheme Tests
    
    @Test func colorSchemeSelection() async {
        let viewModel = SortingViewModel()
        
        viewModel.colorSchemeType = .classic
        #expect(viewModel.currentColors == .classic)
        
        viewModel.colorSchemeType = .vibrant
        #expect(viewModel.currentColors == .vibrant)
        
        viewModel.colorSchemeType = .custom
        #expect(viewModel.currentColors == viewModel.customColors)
    }
    
    // MARK: - Sound Tests
    
    @Test func soundToggle() async {
        let viewModel = SortingViewModel()
        
        #expect(viewModel.soundEnabled == false)
        
        viewModel.soundEnabled = true
        #expect(viewModel.soundEnabled == true)
        #expect(viewModel.soundGenerator.isEnabled == true)
        
        viewModel.soundEnabled = false
        #expect(viewModel.soundEnabled == false)
        #expect(viewModel.soundGenerator.isEnabled == false)
    }
    
    @Test func soundVolumeControl() async {
        let viewModel = SortingViewModel()
        
        viewModel.soundVolume = 0.7
        #expect(viewModel.soundVolume == 0.7)
        #expect(viewModel.soundGenerator.volume == Float(0.7))
        
        viewModel.soundVolume = 0.3
        #expect(viewModel.soundVolume == 0.3)
        #expect(viewModel.soundGenerator.volume == Float(0.3))
    }
    
    // MARK: - Edge Cases
    
    @Test func sortWithMinimumElements() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 10 // Minimum
        viewModel.selectedAlgorithm = .bubble
        viewModel.speed = 0
        
        viewModel.reset()
        #expect(viewModel.bars.count == 10)
        
        viewModel.startSort()
        try? await Task.sleep(for: .seconds(1))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func sortAlreadySortedArray() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 20
        viewModel.selectedAlgorithm = .bubble
        viewModel.speed = 0
        
        // Create pre-sorted array
        viewModel.bars = (1...20).map { Bar(value: $0, state: .unsorted) }
        
        viewModel.startSort()
        try? await Task.sleep(for: .seconds(1))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    @Test func sortReverseSortedArray() async {
        let viewModel = SortingViewModel()
        viewModel.numberOfElements = 20
        viewModel.selectedAlgorithm = .bubble
        viewModel.speed = 0
        
        // Create reverse-sorted array
        viewModel.bars = (1...20).reversed().map { Bar(value: $0, state: .unsorted) }
        
        viewModel.startSort()
        try? await Task.sleep(for: .seconds(1))
        
        #expect(isSorted(viewModel.bars, direction: .ascending))
    }
    
    // MARK: - Helper Functions
    
    private func isSorted(_ bars: [Bar], direction: SortDirection) -> Bool {
        guard bars.count > 1 else { return true }
        
        for i in 0..<(bars.count - 1) {
            switch direction {
            case .ascending:
                if bars[i].value > bars[i + 1].value {
                    return false
                }
            case .descending:
                if bars[i].value < bars[i + 1].value {
                    return false
                }
            }
        }
        return true
    }
}
