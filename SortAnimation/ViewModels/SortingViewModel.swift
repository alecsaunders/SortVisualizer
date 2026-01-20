//
//  SortingViewModel.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SortingViewModel: ObservableObject {
    @Published var bars: [Bar] = []
    @Published var selectedAlgorithm: SortAlgorithm = .bubble
    @Published var sortDirection: SortDirection = .ascending
    @Published var speed: Double = 10 // milliseconds
    @Published var numberOfElements: Int = 100
    @Published var isSorting: Bool = false
    @Published var isPaused: Bool = false
    @Published var sweepVersion: Int = 0 // Force Canvas redraw during sweep
    
    // Performance optimization: working copy for frequent mutations
    private var workingBars: [Bar] = []
    private var lastPublishTime = Date()
    private let publishInterval: TimeInterval = 1.0 / 60.0 // 60fps
    
    // Statistics tracking - throttled for performance
    @Published var comparisonCount: Int = 0
    @Published var swapCount: Int = 0
    @Published var arrayAccessCount: Int = 0
    @Published var elapsedTime: TimeInterval = 0
    private var sortStartTime: Date?
    
    // Working statistics (not published, updated frequently)
    private var workingComparisonCount: Int = 0
    private var workingSwapCount: Int = 0
    private var workingArrayAccessCount: Int = 0
    
    // Color scheme
    @Published var colorSchemeType: ColorSchemeType = .vibrant {
        didSet {
            saveColorScheme()
        }
    }
    @Published var customColors: ColorSchemeColors = .vibrant {
        didSet {
            saveColorScheme()
        }
    }
    
    var currentColors: ColorSchemeColors {
        switch colorSchemeType {
        case .classic:
            return .classic
        case .vibrant:
            return .vibrant
        case .custom:
            return customColors
        }
    }
    
    // Sound settings
    @Published var soundVolume: Double = 0.5 {
        didSet {
            soundGenerator.volume = Float(soundVolume)
        }
    }
    @Published var soundSustain: Double = 0.3 {
        didSet {
            soundGenerator.sustainTime = soundSustain
        }
    }
    @Published var soundEnabled: Bool = false {
        didSet {
            guard soundGenerator.isEnabled != soundEnabled else { return }
            soundGenerator.isEnabled = soundEnabled
        }
    }
    
    let soundGenerator = SoundGenerator()
    
    private var sortTask: Task<Void, Never>?
    private var stepContinuation: CheckedContinuation<Void, Never>?
    
    init() {
        loadColorScheme()
        soundGenerator.volume = Float(soundVolume)
        soundGenerator.sustainTime = soundSustain
        reset()
    }
    
    func reset() {
        sortTask?.cancel()
        stepContinuation?.resume()
        stepContinuation = nil
        isSorting = false
        isPaused = false
        
        // Reset statistics
        comparisonCount = 0
        swapCount = 0
        arrayAccessCount = 0
        elapsedTime = 0
        sortStartTime = nil
        
        // Reset working statistics
        workingComparisonCount = 0
        workingSwapCount = 0
        workingArrayAccessCount = 0
        
        let values = Array(1...numberOfElements).shuffled()
        bars.removeAll(keepingCapacity: true) // Keep capacity for reuse
        bars.reserveCapacity(numberOfElements) // Ensure capacity
        bars = values.map { Bar(value: $0, state: .unsorted) }
        
        // Initialize working copy
        workingBars = bars
        
        // Publish immediately to ensure UI updates with new bars
        publishNow()
        
        lastPublishTime = Date()
    }
    
    func togglePause() {
        isPaused.toggle()
        if !isPaused {
            // Resume from pause
            stepContinuation?.resume()
            stepContinuation = nil
        }
    }
    
    func nextStep() {
        if !isSorting {
            // Start sorting in paused mode
            isPaused = true
            startSort()
        } else {
            // Resume from current step
            stepContinuation?.resume()
            stepContinuation = nil
        }
    }
    
    func startSort() {
        guard !isSorting else { return }
        
        isSorting = true
        workingBars = bars // Initialize working copy
        lastPublishTime = Date()
        
        // Initialize statistics
        comparisonCount = 0
        swapCount = 0
        arrayAccessCount = 0
        elapsedTime = 0
        sortStartTime = Date()
        
        // Initialize working statistics
        workingComparisonCount = 0
        workingSwapCount = 0
        workingArrayAccessCount = 0
        
        sortTask = Task {
            // Update elapsed time periodically
            let timerTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(100))
                    if let startTime = sortStartTime {
                        elapsedTime = Date().timeIntervalSince(startTime)
                    }
                }
            }
            
            switch selectedAlgorithm {
            case .bubble:
                await bubbleSort()
            case .selection:
                await selectionSort()
            case .merge:
                await mergeSort()
            case .insertion:
                await insertionSort()
            case .radix:
                await radixSort()
            case .quick:
                await quickSort()
            case .heap:
                await heapSort()
            case .shell:
                await shellSort()
            case .counting:
                await countingSort()
            case .cocktail:
                await cocktailSort()
            case .gnome:
                await gnomeSort()
            case .comb:
                await combSort()
            case .cycle:
                await cycleSort()
            case .tim:
                await timSort()
            }
            
            timerTask.cancel()
            
            if !Task.isCancelled {
                // Mark all bars as sorted (final state)
                for index in workingBars.indices {
                    workingBars[index].state = .sorted
                }
                publishNow()
                
                // Final sweep animation (Sound of Sorting style)
                // Goes through each bar sequentially to confirm sort completion
                await finalSweep()
                
                // Final elapsed time update
                if let startTime = sortStartTime {
                    elapsedTime = Date().timeIntervalSince(startTime)
                }
                
                isSorting = false
            }
        }
    }
    
    /// Final sweep animation - highlights each bar in sequence with sound
    /// This provides visual and audio confirmation that sorting is complete
    private func finalSweep() async {
        // Calculate sweep speed: faster for fewer elements, capped at reasonable limits
        let perBarDelay = max(5, min(50, 3000 / workingBars.count))
        
        for index in workingBars.indices {
            guard !Task.isCancelled else { break }
            
            // Highlight current bar (red)
            workingBars[index].state = .comparing
            bars = workingBars
            sweepVersion += 1 // Force Canvas redraw
            
            // Play tone for this bar
            playComparisonSound(value1: workingBars[index].value, value2: workingBars[index].value)
            
            // Brief pause to show red bar
            try? await Task.sleep(for: .milliseconds(perBarDelay))
            
            // Return to sorted state (green)
            workingBars[index].state = .sorted
        }
        
        // Final publish to ensure all bars are green
        bars = workingBars
        sweepVersion += 1
    }
    
    // MARK: - Performance Optimization
    
    /// Throttled publish: only update UI at 60fps to reduce SwiftUI overhead
    private func publishIfNeeded() {
        let now = Date()
        if now.timeIntervalSince(lastPublishTime) >= publishInterval {
            bars = workingBars
            // Also publish statistics at the same throttled rate
            comparisonCount = workingComparisonCount
            swapCount = workingSwapCount
            arrayAccessCount = workingArrayAccessCount
            lastPublishTime = now
        }
    }
    
    /// Force immediate publish (used for final state)
    private func publishNow() {
        bars = workingBars
        comparisonCount = workingComparisonCount
        swapCount = workingSwapCount
        arrayAccessCount = workingArrayAccessCount
        lastPublishTime = Date()
    }
    
    // MARK: - Statistics Helpers
    
    private func incrementComparison() {
        workingComparisonCount += 1
    }
    
    private func incrementSwap() {
        workingSwapCount += 1
    }
    
    private func incrementArrayAccess(_ count: Int = 1) {
        workingArrayAccessCount += count
    }
    
    // MARK: - Visualization Helpers
    
    /// Compare two bars with visualization and sound
    private func visualizeComparison(at index1: Int, and index2: Int) {
        workingBars[index1].state = .comparing
        workingBars[index2].state = .comparing
        incrementArrayAccess(2)
        publishIfNeeded()
        playComparisonSound(value1: workingBars[index1].value, value2: workingBars[index2].value)
    }
    
    /// Reset state of bars to unsorted if they're in comparing state
    private func resetComparingBars(at indices: Int...) {
        for index in indices where index >= 0 && index < workingBars.count {
            if workingBars[index].state == .comparing {
                workingBars[index].state = .unsorted
                incrementArrayAccess()
            }
        }
    }
    
    /// Mark all remaining bars as sorted (used at end of algorithms)
    private func markAllAsSorted() {
        for index in workingBars.indices {
            workingBars[index].state = .sorted
        }
        publishNow()
    }
    
    /// Compare two values based on sort direction for min/max selection
    private func compare(_ value1: Int, _ value2: Int) -> Bool {
        sortDirection == .ascending ? value1 < value2 : value1 > value2
    }
    
    /// Compare two values based on sort direction for ordering (≤ or ≥)
    private func compareOrEqual(_ value1: Int, _ value2: Int) -> Bool {
        sortDirection == .ascending ? value1 <= value2 : value1 >= value2
    }
    
    private func bubbleSort() async {
        let n = workingBars.count
        
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            
            var swapped = false
            for j in 0..<(n - i - 1) {
                guard !Task.isCancelled else { break }
                
                // Visualize comparison
                visualizeComparison(at: j, and: j + 1)
                
                if shouldSwap(workingBars[j].value, workingBars[j + 1].value) {
                    await swapBars(at: j, and: j + 1)
                    swapped = true
                }
                
                // Reset comparing state
                resetComparingBars(at: j, j + 1)
                publishIfNeeded()
            }
            
            // Mark the last element of this pass as sorted
            if i < n {
                workingBars[n - i - 1].state = .sorted
                incrementArrayAccess()
                publishIfNeeded()
            }
            
            if !swapped { break }
        }
    }
    
    private func selectionSort() async {
        let n = workingBars.count
        
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            
            var targetIndex = i
            workingBars[targetIndex].state = .comparing
            publishNow()
            
            for j in (i + 1)..<n {
                guard !Task.isCancelled else { break }
                
                workingBars[j].state = .comparing
                publishNow()
                await delay(Int(speed / 2))
                
                playComparisonSound(value1: workingBars[j].value, value2: workingBars[targetIndex].value)
                
                if compare(workingBars[j].value, workingBars[targetIndex].value) {
                    // Reset previous target
                    resetComparingBars(at: targetIndex)
                    targetIndex = j
                    workingBars[targetIndex].state = .comparing
                } else {
                    // Reset if not the target
                    if j != targetIndex {
                        resetComparingBars(at: j)
                    }
                }
                publishNow()
            }
            
            if targetIndex != i {
                await swapBars(at: i, and: targetIndex)
            }
            
            workingBars[i].state = .sorted
            publishNow()
        }
    }
    
    @MainActor
    private func swapBars(at index1: Int, and index2: Int) async {
        guard index1 != index2, index1 >= 0, index2 >= 0, 
              index1 < workingBars.count, index2 < workingBars.count else { return }
        
        // Track statistics
        incrementSwap()
        incrementArrayAccess(4) // 2 reads + 2 writes
        
        // Calculate the distance between bars
        let distance = CGFloat(abs(index2 - index1))
        
        // Set offsets for animation
        if index1 < index2 {
            workingBars[index1].offset = distance
            workingBars[index2].offset = -distance
        } else {
            workingBars[index1].offset = -distance
            workingBars[index2].offset = distance
        }
        
        // Publish for visual animation
        publishIfNeeded()
        
        // Animate the swap
        withAnimation(.linear(duration: speed / 1000.0)) {
            workingBars[index1].offset = workingBars[index1].offset
            workingBars[index2].offset = workingBars[index2].offset
        }
        
        // Wait for animation plus speed delay
        await delay(Int(speed))
        
        // Actually swap the bars
        workingBars.swapAt(index1, index2)
        
        // Reset offsets
        workingBars[index1].offset = 0
        workingBars[index2].offset = 0
        
        // Publish after swap
        publishIfNeeded()
    }
    
    private func waitForStep() async {
        await withCheckedContinuation { continuation in
            stepContinuation = continuation
        }
    }
    
    private func delay(_ milliseconds: Int) async {
        if isPaused {
            await waitForStep()
        } else {
            try? await Task.sleep(for: .milliseconds(milliseconds))
        }
    }
    
    // Helper function to compare values based on sort direction
    private func shouldSwap(_ value1: Int, _ value2: Int) -> Bool {
        switch sortDirection {
        case .ascending:
            return value1 > value2
        case .descending:
            return value1 < value2
        }
    }
    
    private func playComparisonSound(value1: Int, value2: Int) {
        incrementComparison()
        incrementArrayAccess(2) // 2 reads for comparison
        soundGenerator.playComparison(
            value1: value1,
            value2: value2,
            maxValue: numberOfElements,
            duration: min(Double(speed) / 1000.0, 0.2)
        )
    }
    
    private func insertionSort() async {
        let n = workingBars.count
        
        for i in 1..<n {
            guard !Task.isCancelled else { break }
            
            let key = workingBars[i]
            workingBars[i].state = .comparing
            publishIfNeeded()
            var j = i - 1
            
            // Find the correct position for the key
            while j >= 0 && shouldSwap(workingBars[j].value, key.value) {
                guard !Task.isCancelled else { break }
                
                workingBars[j].state = .comparing
                workingBars[j + 1].state = .comparing
                publishIfNeeded()
                
                // Play comparison sound
                playComparisonSound(value1: workingBars[j].value, value2: key.value)
                
                // Shift element to the right
                await swapBars(at: j, and: j + 1)
                
                workingBars[j + 1].state = .unsorted
                publishIfNeeded()
                j -= 1
            }
            
            // Mark elements before current position as sorted
            for k in 0...i {
                if workingBars[k].state != .comparing {
                    workingBars[k].state = .unsorted
                }
            }
            publishIfNeeded()
        }
    }
    
    private func mergeSort() async {
        print("🔷 Starting Merge Sort with \(workingBars.count) elements")
        await mergeSortHelper(start: 0, end: workingBars.count - 1)
        print("✅ Merge Sort complete")
    }
    
    private func mergeSortHelper(start: Int, end: Int) async {
        guard start < end, !Task.isCancelled else { return }
        
        let mid = start + (end - start) / 2
        print("📊 Dividing range [\(start)..\(end)] at mid=\(mid)")
        
        // Sort left half
        print("  ⬅️ Sorting left half [\(start)..\(mid)]")
        await mergeSortHelper(start: start, end: mid)
        
        // Sort right half
        print("  ➡️ Sorting right half [\(mid + 1)..\(end)]")
        await mergeSortHelper(start: mid + 1, end: end)
        
        // Merge the two halves
        print("  🔀 Merging [\(start)..\(mid)] and [\(mid + 1)..\(end)]")
        await merge(start: start, mid: mid, end: end)
    }
    
    private func merge(start: Int, mid: Int, end: Int) async {
        guard !Task.isCancelled else { return }
        
        print("    🔄 Merge started: range [\(start)..\(end)], mid=\(mid)")
        
        // Create copies of the subarrays
        let leftArray = Array(workingBars[start...mid])
        let rightArray = Array(workingBars[(mid + 1)...end])
        
        print("      Left:  [\(leftArray.map { String($0.value) }.joined(separator: ", "))]")
        print("      Right: [\(rightArray.map { String($0.value) }.joined(separator: ", "))]")
        
        var i = 0, j = 0, k = start
        
        // Merge the arrays back
        while i < leftArray.count && j < rightArray.count {
            guard !Task.isCancelled else { break }
            
            print("      Comparing: left[\(i)]=\(leftArray[i].value) vs right[\(j)]=\(rightArray[j].value) → position [\(k)]")
            playComparisonSound(value1: leftArray[i].value, value2: rightArray[j].value)
            
            if compareOrEqual(leftArray[i].value, rightArray[j].value) {
                print("        ✓ Taking left[\(i)]=\(leftArray[i].value)")
                workingBars[k] = leftArray[i]
                i += 1
            } else {
                print("        ✓ Taking right[\(j)]=\(rightArray[j].value)")
                workingBars[k] = rightArray[j]
                j += 1
            }
            
            workingBars[k].state = .comparing
            publishNow()
            try? await Task.sleep(for: .milliseconds(Int(speed)))
            workingBars[k].state = .unsorted
            publishNow()
            k += 1
        }
        
        // Copy remaining elements from left array
        while i < leftArray.count {
            guard !Task.isCancelled else { break }
            print("      Copying remaining left[\(i)]=\(leftArray[i].value) → position [\(k)]")
            workingBars[k] = leftArray[i]
            workingBars[k].state = .comparing
            publishNow()
            await delay(Int(speed))
            workingBars[k].state = .unsorted
            publishNow()
            i += 1
            k += 1
        }
        
        // Copy remaining elements from right array
        while j < rightArray.count {
            guard !Task.isCancelled else { break }
            print("      Copying remaining right[\(j)]=\(rightArray[j].value) → position [\(k)]")
            workingBars[k] = rightArray[j]
            workingBars[k].state = .comparing
            publishNow()
            await delay(Int(speed))
            workingBars[k].state = .unsorted
            publishNow()
            j += 1
            k += 1
        }
        
        print("    ✅ Merge complete: [\(workingBars[start...end].map { String($0.value) }.joined(separator: ", "))]")
    }
    
    private func radixSort() async {
        guard !Task.isCancelled else { return }
        
        let maxValue = workingBars.max(by: { $0.value < $1.value })?.value ?? 0
        var exp = 1
        
        while maxValue / exp > 0 {
            guard !Task.isCancelled else { break }
            await countingSort(exp: exp)
            exp *= 10
        }
        
        // If descending, reverse the final result
        if sortDirection == .descending {
            workingBars = workingBars.reversed()
            // Animate the reversed result
            for i in 0..<workingBars.count {
                guard !Task.isCancelled else { break }
                workingBars[i].state = .comparing
                publishIfNeeded()
                await delay(Int(speed))
                workingBars[i].state = .sorted
                publishIfNeeded()
            }
        }
        
        markAllAsSorted()
    }
    
    private func countingSort(exp: Int) async {
        guard !Task.isCancelled else { return }
        
        let n = workingBars.count
        var output = [Bar]()
        output.reserveCapacity(n)
        output.append(contentsOf: repeatElement(Bar(value: 0), count: n))
        var count = Array(repeating: 0, count: 10)
        
        // Mark all bars as comparing during counting phase
        for i in 0..<n {
            workingBars[i].state = .comparing
        }
        publishIfNeeded()
        await delay(Int(speed / 2))
        
        // Store count of occurrences
        for i in 0..<n {
            let digit = (workingBars[i].value / exp) % 10
            count[digit] += 1
        }
        
        // Change count[i] to contain actual position
        for i in 1..<10 {
            count[i] += count[i - 1]
        }
        
        // Build output array
        for i in stride(from: n - 1, through: 0, by: -1) {
            guard !Task.isCancelled else { break }
            
            let digit = (workingBars[i].value / exp) % 10
            output[count[digit] - 1] = workingBars[i]
            count[digit] -= 1
        }
        
        // Replace bars array with sorted output
        workingBars = output
        publishNow()
        
        // Note: No animation here since this is called multiple times by radixSort
        // The final sorted state will be shown by radixSort's cleanup
    }
    
    // MARK: - Quick Sort
    
    private func quickSort() async {
        await quickSortHelper(low: 0, high: workingBars.count - 1)
        markAllAsSorted()
    }
    
    private func quickSortHelper(low: Int, high: Int) async {
        guard low < high, !Task.isCancelled else { return }
        
        let pivotIndex = await partition(low: low, high: high)
        
        await quickSortHelper(low: low, high: pivotIndex - 1)
        await quickSortHelper(low: pivotIndex + 1, high: high)
    }
    
    private func partition(low: Int, high: Int) async -> Int {
        guard !Task.isCancelled else { return low }
        
        let pivot = workingBars[high]
        workingBars[high].state = .pivot
        publishNow()
        var i = low - 1
        
        for j in low..<high {
            guard !Task.isCancelled else { break }
            
            workingBars[j].state = .comparing
            if i >= low && i < workingBars.count {
                workingBars[i].state = .pointer
            }
            publishNow()
            await delay(Int(speed / 2))
            
            playComparisonSound(value1: workingBars[j].value, value2: pivot.value)
            
            if compare(workingBars[j].value, pivot.value) {
                // Reset previous pointer
                if i >= 0 && i < workingBars.count {
                    workingBars[i].state = .unsorted
                }
                i += 1
                if i != j {
                    await swapBars(at: i, and: j)
                }
            }
            
            // Clear states - reset both comparing and pointer
            workingBars[j].state = .unsorted
            if i >= 0 && i < workingBars.count {
                workingBars[i].state = .unsorted
            }
            publishNow()
        }
        
        // Reset pivot state before swap
        workingBars[high].state = .unsorted
        publishNow()
        
        // Place pivot in correct position
        await swapBars(at: i + 1, and: high)
        
        // Mark pivot as sorted - it's now in its final position
        workingBars[i + 1].state = .sorted
        publishNow()
        
        return i + 1
    }
    
    // MARK: - Heap Sort
    
    private func heapSort() async {
        let n = workingBars.count
        
        // Build max heap
        for i in stride(from: n / 2 - 1, through: 0, by: -1) {
            guard !Task.isCancelled else { break }
            await heapify(n: n, root: i)
        }
        
        // Extract elements from heap one by one
        for i in stride(from: n - 1, through: 1, by: -1) {
            guard !Task.isCancelled else { break }
            
            workingBars[0].state = .comparing
            workingBars[i].state = .comparing
            publishIfNeeded()
            
            await swapBars(at: 0, and: i)
            workingBars[i].state = .sorted
            publishIfNeeded()
            
            await heapify(n: i, root: 0)
        }
        
        if !Task.isCancelled && n > 0 {
            workingBars[0].state = .sorted
            publishIfNeeded()
        }
    }
    
    private func heapify(n: Int, root: Int) async {
        guard !Task.isCancelled else { return }
        
        var target = root
        let left = 2 * root + 1
        let right = 2 * root + 2
        
        // Check left child
        if left < n {
            workingBars[left].state = .comparing
            publishIfNeeded()
            await delay(Int(speed / 2))
            
            playComparisonSound(value1: workingBars[left].value, value2: workingBars[target].value)
            
            // For ascending: build max heap; for descending: build min heap
            if sortDirection == .ascending ?
                workingBars[left].value > workingBars[target].value :
                workingBars[left].value < workingBars[target].value {
                target = left
            }
            workingBars[left].state = .unsorted
            publishIfNeeded()
        }
        
        // Check right child
        if right < n {
            workingBars[right].state = .comparing
            publishIfNeeded()
            await delay(Int(speed / 2))
            
            playComparisonSound(value1: workingBars[right].value, value2: workingBars[target].value)
            
            // For ascending: build max heap; for descending: build min heap
            if sortDirection == .ascending ?
                workingBars[right].value > workingBars[target].value :
                workingBars[right].value < workingBars[target].value {
                target = right
            }
            workingBars[right].state = .unsorted
            publishIfNeeded()
        }
        
        // Swap if needed and recursively heapify
        if target != root {
            workingBars[root].state = .comparing
            workingBars[target].state = .comparing
            publishIfNeeded()
            await swapBars(at: root, and: target)
            resetComparingBars(at: root, target)
            publishIfNeeded()
            
            await heapify(n: n, root: target)
        }
    }
    
    // MARK: - Shell Sort
    
    private func shellSort() async {
        let n = workingBars.count
        var gap = n / 2
        
        while gap > 0 {
            guard !Task.isCancelled else { break }
            
            for i in gap..<n {
                guard !Task.isCancelled else { break }
                
                let temp = workingBars[i]
                workingBars[i].state = .comparing
                publishNow()
                var j = i
                
                while j >= gap && shouldSwap(workingBars[j - gap].value, temp.value) {
                    guard !Task.isCancelled else { break }
                    
                    // Show both elements being compared
                    workingBars[j - gap].state = .comparing
                    workingBars[j].state = .comparing
                    publishNow()
                    
                    playComparisonSound(value1: workingBars[j - gap].value, value2: temp.value)
                    
                    await swapBars(at: j, and: j - gap)
                    
                    // Reset both after swap
                    workingBars[j].state = .unsorted
                    workingBars[j - gap].state = .unsorted
                    publishNow()
                    j -= gap
                }
                
                // Reset the original position
                if j < n {
                    workingBars[j].state = .unsorted
                }
                // Reset the initial i position if not part of the comparison
                if i < n && i != j {
                    workingBars[i].state = .unsorted
                }
                publishNow()
            }
            
            gap /= 2
        }
        
        markAllAsSorted()
    }
    
    // MARK: - Counting Sort
    
    private func countingSort() async {
        guard !Task.isCancelled else { return }
        
        let n = workingBars.count
        let maxValue = workingBars.max(by: { $0.value < $1.value })?.value ?? 0
        let minValue = workingBars.min(by: { $0.value < $1.value })?.value ?? 0
        let range = maxValue - minValue + 1
        
        var count = Array(repeating: 0, count: range)
        
        // Store count of each element and mark as comparing
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            workingBars[i].state = .comparing
            count[workingBars[i].value - minValue] += 1
            publishIfNeeded()
            await delay(Int(speed / 2))
        }
        
        // Build the sorted output array
        let originalBars = workingBars
        
        // Calculate cumulative count
        for i in 1..<range {
            count[i] += count[i - 1]
        }
        
        // Build output array in correct sorted order
        var output = [Bar]()
        output.reserveCapacity(n)
        output.append(contentsOf: repeatElement(Bar(value: 0), count: n))
        
        for i in stride(from: n - 1, through: 0, by: -1) {
            guard !Task.isCancelled else { break }
            
            let index = originalBars[i].value - minValue
            output[count[index] - 1] = originalBars[i]
            count[index] -= 1
        }
        
        // Replace array with sorted output
        workingBars = sortDirection == .ascending ? output : output.reversed()
        markAllAsSorted()
    }
    
    // MARK: - Cocktail Shaker Sort
    
    private func cocktailSort() async {
        var swapped = true
        var start = 0
        var end = workingBars.count - 1
        
        while swapped {
            guard !Task.isCancelled else { break }
            swapped = false
            
            // Forward pass (left to right)
            for i in start..<end {
                guard !Task.isCancelled else { break }
                
                visualizeComparison(at: i, and: i + 1)
                
                if shouldSwap(workingBars[i].value, workingBars[i + 1].value) {
                    await swapBars(at: i, and: i + 1)
                    swapped = true
                }
                
                resetComparingBars(at: i, i + 1)
                publishIfNeeded()
            }
            
            if !swapped { break }
            
            workingBars[end].state = .sorted
            publishIfNeeded()
            end -= 1
            swapped = false
            
            // Backward pass (right to left)
            for i in stride(from: end, through: start, by: -1) {
                guard !Task.isCancelled else { break }
                
                visualizeComparison(at: i, and: i + 1)
                
                if shouldSwap(workingBars[i].value, workingBars[i + 1].value) {
                    await swapBars(at: i, and: i + 1)
                    swapped = true
                }
                
                resetComparingBars(at: i, i + 1)
                publishIfNeeded()
            }
            
            workingBars[start].state = .sorted
            publishIfNeeded()
            start += 1
        }
        
        // Mark remaining unsorted as sorted
        for i in start...end {
            workingBars[i].state = .sorted
        }
        publishIfNeeded()
    }
    
    // MARK: - Gnome Sort
    
    private func gnomeSort() async {
        var index = 0
        
        while index < workingBars.count {
            guard !Task.isCancelled else { break }
            
            if index == 0 {
                index += 1
            } else {
                // Show comparison between current and previous element
                workingBars[index].state = .comparing
                workingBars[index - 1].state = .comparing
                publishNow()
                await delay(Int(speed / 2))
                
                playComparisonSound(value1: workingBars[index - 1].value, value2: workingBars[index].value)
                
                if shouldSwap(workingBars[index - 1].value, workingBars[index].value) {
                    // Need to swap - move back
                    await swapBars(at: index, and: index - 1)
                    
                    // Reset both positions after swap
                    workingBars[index].state = .unsorted
                    workingBars[index - 1].state = .unsorted
                    publishNow()
                    
                    index -= 1
                } else {
                    // In correct order - move forward
                    workingBars[index].state = .unsorted
                    workingBars[index - 1].state = .unsorted
                    publishNow()
                    
                    index += 1
                }
            }
        }
        
        markAllAsSorted()
    }
    
    // MARK: - Comb Sort
    
    private func combSort() async {
        var gap = workingBars.count
        let shrink: Double = 1.3
        var sorted = false
        
        while !sorted {
            guard !Task.isCancelled else { break }
            
            // Update gap value
            gap = Int(Double(gap) / shrink)
            if gap <= 1 {
                gap = 1
                sorted = true
            }
            
            // Compare all elements with current gap
            var i = 0
            while i + gap < workingBars.count {
                guard !Task.isCancelled else { break }
                
                visualizeComparison(at: i, and: i + gap)
                
                if shouldSwap(workingBars[i].value, workingBars[i + gap].value) {
                    await swapBars(at: i, and: i + gap)
                    sorted = false
                }
                
                resetComparingBars(at: i, i + gap)
                publishIfNeeded()
                i += 1
            }
        }
        
        markAllAsSorted()
    }
    
    // MARK: - Cycle Sort
    
    private func cycleSort() async {
        let n = workingBars.count
        
        // Loop through the array to find cycles
        for cycleStart in 0..<(n - 1) {
            guard !Task.isCancelled else { break }
            
            let item = workingBars[cycleStart]
            workingBars[cycleStart].state = .pointer  // Cyan - marks cycle start
            publishNow()
            
            // Find position where we put the item
            var pos = cycleStart
            for i in (cycleStart + 1)..<n {
                guard !Task.isCancelled else { break }
                
                // Skip already sorted elements
                if workingBars[i].state == .sorted {
                    if compare(workingBars[i].value, item.value) {
                        pos += 1
                    }
                    continue
                }
                
                workingBars[i].state = .comparing  // Red - current comparison
                publishNow()
                
                playComparisonSound(value1: workingBars[i].value, value2: item.value)
                await delay(Int(speed))
                
                if compare(workingBars[i].value, item.value) {
                    pos += 1
                }
                
                // Reset to unsorted
                workingBars[i].state = .unsorted
                publishNow()
            }
            
            // If item is already in correct position
            if pos == cycleStart {
                workingBars[cycleStart].state = .sorted  // Green - in final position
                publishNow()
                continue
            }
            
            // Skip duplicates
            while pos < n && item.value == workingBars[pos].value {
                pos += 1
            }
            
            // Mark target position briefly with pivot color (green in Classic)
            if pos < n && pos != cycleStart {
                print("🟢 Setting pivot state at index \(pos), current state: \(workingBars[pos].state)")
                workingBars[pos].state = .pivot
                publishNow()
                print("🟢 After setting: \(workingBars[pos].state), bars[\(pos)].state: \(bars[pos].state)")
                await delay(Int(speed * 2))  // Show pivot longer
                print("🟢 After delay, about to swap")
            }
            
            // Put the item to its right position
            if pos != cycleStart && pos < n {
                await swapBars(at: cycleStart, and: pos)
            }
            
            // Rotate rest of the cycle
            var currentPos = pos
            var iterationCount = 0
            
            while currentPos != cycleStart {
                iterationCount += 1
                
                if iterationCount > n {
                    break
                }
                
                guard !Task.isCancelled else { break }
                
                // The item at cycleStart is what was displaced by the last swap
                let currentItem = workingBars[cycleStart]
                
                // Keep cycleStart marked as pointer (cyan)
                workingBars[cycleStart].state = .pointer
                publishNow()
                
                // Find where this displaced item should go
                pos = cycleStart
                for i in (cycleStart + 1)..<n {
                    guard !Task.isCancelled else { break }
                    
                    // Skip already sorted elements
                    if workingBars[i].state == .sorted {
                        if compare(workingBars[i].value, currentItem.value) {
                            pos += 1
                        }
                        continue
                    }
                    
                    workingBars[i].state = .comparing  // Red - current comparison
                    publishNow()
                    
                    playComparisonSound(value1: workingBars[i].value, value2: currentItem.value)
                    await delay(Int(speed))
                    
                    if compare(workingBars[i].value, currentItem.value) {
                        pos += 1
                    }
                    
                    // Reset to unsorted
                    workingBars[i].state = .unsorted
                    publishNow()
                }
                
                // If the position equals cycleStart, the cycle is complete!
                if pos == cycleStart {
                    break
                }
                
                // Skip duplicates
                while pos < n && currentItem.value == workingBars[pos].value {
                    pos += 1
                }
                
                // Safety check for bounds
                if pos >= n {
                    break
                }
                
                // Mark target position briefly with pivot color
                workingBars[pos].state = .pivot
                publishNow()
                await delay(Int(speed * 2))  // Show pivot longer
                
                // Swap to continue the cycle
                await swapBars(at: cycleStart, and: pos)
                
                // Keep cycleStart marked as pointer after swap
                workingBars[cycleStart].state = .pointer
                publishNow()
                
                currentPos = pos
            }
            
            // Mark this position as sorted (green) - it's now in final position
            workingBars[cycleStart].state = .sorted
            publishNow()
        }
        
        // Mark last element as sorted
        if n > 0 {
            workingBars[n - 1].state = .sorted
        }
        publishNow()
    }
    
    // MARK: - Tim Sort
    
    private func timSort() async {
        let minRun = 32
        let n = workingBars.count
        
        // Sort individual runs using insertion sort
        var start = 0
        while start < n {
            guard !Task.isCancelled else { break }
            
            let end = min(start + minRun - 1, n - 1)
            await timInsertionSort(left: start, right: end)
            
            // Mark this run as processed
            for i in start...end {
                if i < workingBars.count {
                    workingBars[i].state = .pointer
                }
            }
            publishNow()
            await delay(Int(speed))
            
            // Reset pointer state
            for i in start...end {
                if i < workingBars.count {
                    workingBars[i].state = .unsorted
                }
            }
            
            start += minRun
        }
        
        // Merge sorted runs
        var size = minRun
        while size < n {
            guard !Task.isCancelled else { break }
            
            var left = 0
            while left < n {
                guard !Task.isCancelled else { break }
                
                let mid = left + size - 1
                let right = min(left + size * 2 - 1, n - 1)
                
                if mid < right {
                    await timMerge(left: left, mid: mid, right: right)
                }
                
                left += size * 2
            }
            size *= 2
        }
        
        markAllAsSorted()
    }
    
    private func timInsertionSort(left: Int, right: Int) async {
        for i in (left + 1)...right {
            guard !Task.isCancelled else { break }
            guard i < workingBars.count else { break }
            
            let key = workingBars[i]
            var j = i - 1
            
            while j >= left {
                guard !Task.isCancelled else { break }
                guard j < workingBars.count else { break }
                
                if shouldSwap(workingBars[j].value, key.value) {
                    // Show comparison
                    workingBars[j].state = .comparing
                    workingBars[j + 1].state = .comparing
                    publishNow()
                    
                    playComparisonSound(value1: workingBars[j].value, value2: key.value)
                    
                    await swapBars(at: j, and: j + 1)
                    
                    // Reset both bars after swap
                    workingBars[j].state = .unsorted
                    workingBars[j + 1].state = .unsorted
                    publishNow()
                    j -= 1
                } else {
                    break
                }
            }
        }
    }
    
    private func timMerge(left: Int, mid: Int, right: Int) async {
        guard !Task.isCancelled else { return }
        guard left < workingBars.count && mid < workingBars.count && right < workingBars.count else { return }
        
        let leftArray = Array(workingBars[left...mid])
        let rightArray = Array(workingBars[(mid + 1)...right])
        
        var i = 0, j = 0, k = left
        
        while i < leftArray.count && j < rightArray.count {
            guard !Task.isCancelled else { break }
            guard k < workingBars.count else { break }
            
            playComparisonSound(value1: leftArray[i].value, value2: rightArray[j].value)
            
            if compareOrEqual(leftArray[i].value, rightArray[j].value) {
                workingBars[k] = leftArray[i]
                i += 1
            } else {
                workingBars[k] = rightArray[j]
                j += 1
            }
            
            workingBars[k].state = .comparing
            publishNow()
            await delay(Int(speed))
            workingBars[k].state = .unsorted
            publishNow()
            k += 1
        }
        
        while i < leftArray.count {
            guard !Task.isCancelled else { break }
            guard k < workingBars.count else { break }
            
            workingBars[k] = leftArray[i]
            workingBars[k].state = .comparing
            publishNow()
            await delay(Int(speed))
            workingBars[k].state = .unsorted
            publishNow()
            i += 1
            k += 1
        }
        
        while j < rightArray.count {
            guard !Task.isCancelled else { break }
            guard k < workingBars.count else { break }
            
            workingBars[k] = rightArray[j]
            workingBars[k].state = .comparing
            publishNow()
            await delay(Int(speed))
            workingBars[k].state = .unsorted
            publishNow()
            j += 1
            k += 1
        }
    }
    
    // MARK: - Persistence
    
    private func loadColorScheme() {
        if let typeString = UserDefaults.standard.string(forKey: "colorSchemeType"),
           let type = ColorSchemeType(rawValue: typeString) {
            colorSchemeType = type
        }
        
        if let customData = UserDefaults.standard.data(forKey: "customColors"),
           let colors = try? JSONDecoder().decode(ColorSchemeColors.self, from: customData) {
            customColors = colors
        }
    }
    
    private func saveColorScheme() {
        UserDefaults.standard.set(colorSchemeType.rawValue, forKey: "colorSchemeType")
        
        if let customData = try? JSONEncoder().encode(customColors) {
            UserDefaults.standard.set(customData, forKey: "customColors")
        }
    }
}
