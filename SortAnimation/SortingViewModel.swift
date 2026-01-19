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
    @Published var colorSchemeType: ColorSchemeType = .educational {
        didSet {
            saveColorScheme()
        }
    }
    @Published var customColors: ColorSchemeColors = .educational {
        didSet {
            saveColorScheme()
        }
    }
    
    var currentColors: ColorSchemeColors {
        switch colorSchemeType {
        case .classic:
            return .classic
        case .educational:
            return .educational
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
            }
            
            timerTask.cancel()
            
            if !Task.isCancelled {
                // Mark all bars as sorted
                for index in workingBars.indices {
                    workingBars[index].state = .sorted
                }
                
                // Force final publish immediately to show all green bars
                publishNow()
                
                // Add a brief pause to let users see the final sorted state
                try? await Task.sleep(for: .milliseconds(100))
                
                // Final elapsed time update
                if let startTime = sortStartTime {
                    elapsedTime = Date().timeIntervalSince(startTime)
                }
                
                isSorting = false
            }
        }
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
    
    private func bubbleSort() async {
        let n = workingBars.count
        
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            
            var swapped = false
            for j in 0..<(n - i - 1) {
                guard !Task.isCancelled else { break }
                
                // Mark bars being compared
                workingBars[j].state = .comparing
                workingBars[j + 1].state = .comparing
                incrementArrayAccess(2)
                publishIfNeeded()
                
                // Play comparison sound (tracks comparison + 2 accesses)
                playComparisonSound(value1: workingBars[j].value, value2: workingBars[j + 1].value)
                
                if shouldSwap(workingBars[j].value, workingBars[j + 1].value) {
                    // Perform swap with animation (tracks swap + 4 accesses)
                    await swapBars(at: j, and: j + 1)
                    swapped = true
                }
                
                // Reset state after comparison
                if workingBars[j].state == .comparing {
                    workingBars[j].state = .unsorted
                    incrementArrayAccess()
                }
                if workingBars[j + 1].state == .comparing {
                    workingBars[j + 1].state = .unsorted
                    incrementArrayAccess()
                }
                publishIfNeeded()
            }
            
            // Mark the last element of this pass as sorted
            if i < n {
                workingBars[n - i - 1].state = .sorted
                incrementArrayAccess()
                publishIfNeeded()
            }
            
            if !swapped {
                break
            }
        }
    }
    
    private func selectionSort() async {
        let n = workingBars.count
        
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            
            var targetIndex = i
            workingBars[targetIndex].state = .comparing
            publishIfNeeded()
            
            for j in (i + 1)..<n {
                guard !Task.isCancelled else { break }
                
                workingBars[j].state = .comparing
                publishIfNeeded()
                
                // Small delay to visualize comparison
                await delay(Int(speed / 2))
                
                // Play comparison sound
                playComparisonSound(value1: workingBars[j].value, value2: workingBars[targetIndex].value)
                
                // For ascending: find minimum; for descending: find maximum
                let shouldUpdate = sortDirection == .ascending ? 
                    workingBars[j].value < workingBars[targetIndex].value : 
                    workingBars[j].value > workingBars[targetIndex].value
                
                if shouldUpdate {
                    // Reset previous target
                    if workingBars[targetIndex].state == .comparing {
                        workingBars[targetIndex].state = .unsorted
                    }
                    targetIndex = j
                    workingBars[targetIndex].state = .comparing
                } else {
                    // Reset if not the target
                    if workingBars[j].state == .comparing && j != targetIndex {
                        workingBars[j].state = .unsorted
                    }
                }
                publishIfNeeded()
            }
            
            if targetIndex != i {
                await swapBars(at: i, and: targetIndex)
            } else {
                // No swap needed, just mark as sorted
                workingBars[i].state = .sorted
            }
            
            // Mark the position as sorted
            workingBars[i].state = .sorted
            publishIfNeeded()
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
        await mergeSortHelper(start: 0, end: workingBars.count - 1)
    }
    
    private func mergeSortHelper(start: Int, end: Int) async {
        guard start < end, !Task.isCancelled else { return }
        
        let mid = start + (end - start) / 2
        
        // Sort left half
        await mergeSortHelper(start: start, end: mid)
        
        // Sort right half
        await mergeSortHelper(start: mid + 1, end: end)
        
        // Merge the two halves
        await merge(start: start, mid: mid, end: end)
    }
    
    private func merge(start: Int, mid: Int, end: Int) async {
        guard !Task.isCancelled else { return }
        
        // Create copies of the subarrays
        let leftArray = Array(workingBars[start...mid])
        let rightArray = Array(workingBars[(mid + 1)...end])
        
        var i = 0
        var j = 0
        var k = start
        
        // Merge the arrays back
        while i < leftArray.count && j < rightArray.count {
            guard !Task.isCancelled else { break }
            
            // Play comparison sound
            playComparisonSound(value1: leftArray[i].value, value2: rightArray[j].value)
            
            // For ascending: pick smaller; for descending: pick larger
            let shouldPickLeft = sortDirection == .ascending ?
                leftArray[i].value <= rightArray[j].value :
                leftArray[i].value >= rightArray[j].value
            
            if shouldPickLeft {
                workingBars[k] = leftArray[i]
                i += 1
            } else {
                workingBars[k] = rightArray[j]
                j += 1
            }
            
            workingBars[k].state = .comparing
            publishIfNeeded()
            try? await Task.sleep(for: .milliseconds(Int(speed)))
            workingBars[k].state = .unsorted
            publishIfNeeded()
            k += 1
        }
        
        // Copy remaining elements from left array
        while i < leftArray.count {
            guard !Task.isCancelled else { break }
            workingBars[k] = leftArray[i]
            workingBars[k].state = .comparing
            publishIfNeeded()
            await delay(Int(speed))
            workingBars[k].state = .unsorted
            publishIfNeeded()
            i += 1
            k += 1
        }
        
        // Copy remaining elements from right array
        while j < rightArray.count {
            guard !Task.isCancelled else { break }
            workingBars[k] = rightArray[j]
            workingBars[k].state = .comparing
            publishIfNeeded()
            await delay(Int(speed))
            workingBars[k].state = .unsorted
            publishIfNeeded()
            j += 1
            k += 1
        }
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
        
        // Ensure all bars are marked as sorted (important for ascending)
        for index in workingBars.indices {
            workingBars[index].state = .sorted
        }
        publishNow()
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
        
        // Immediately set ALL bars to sorted state and publish
        for index in workingBars.indices {
            workingBars[index].state = .sorted
        }
        // Force immediate publish to avoid any race conditions with throttling
        publishNow()
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
        workingBars[high].state = .pivot  // Mark pivot with green
        publishIfNeeded()
        var i = low - 1
        
        for j in low..<high {
            guard !Task.isCancelled else { break }
            
            workingBars[j].state = .comparing
            
            // Show partition boundary pointer if valid
            if i >= low {
                workingBars[i].state = .pointer
            }
            publishIfNeeded()
            
            await delay(Int(speed / 2))
            
            // Play comparison sound
            playComparisonSound(value1: workingBars[j].value, value2: pivot.value)
            
            // For ascending: elements < pivot go left; for descending: elements > pivot go left
            let shouldSwapToLeft = sortDirection == .ascending ?
                workingBars[j].value < pivot.value :
                workingBars[j].value > pivot.value
            
            if shouldSwapToLeft {
                // Reset previous pointer
                if i >= low && workingBars[i].state == .pointer {
                    workingBars[i].state = .unsorted
                }
                
                i += 1
                if i != j {
                    await swapBars(at: i, and: j)
                }
            }
            
            // Clear pointer state
            if i >= low && workingBars[i].state == .pointer {
                workingBars[i].state = .unsorted
            }
            
            if workingBars[j].state == .comparing {
                workingBars[j].state = .unsorted
            }
            publishIfNeeded()
        }
        
        // Reset pivot state before swap
        workingBars[high].state = .unsorted
        publishIfNeeded()
        
        await swapBars(at: i + 1, and: high)
        workingBars[i + 1].state = .sorted
        publishIfNeeded()
        
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
        
        if left < n {
            workingBars[left].state = .comparing
            publishIfNeeded()
            await delay(Int(speed / 2))
            
            // Play comparison sound
            playComparisonSound(value1: workingBars[left].value, value2: workingBars[target].value)
            
            // For ascending: build max heap; for descending: build min heap
            let shouldUpdate = sortDirection == .ascending ?
                workingBars[left].value > workingBars[target].value :
                workingBars[left].value < workingBars[target].value
            
            if shouldUpdate {
                target = left
            }
            workingBars[left].state = .unsorted
            publishIfNeeded()
        }
        
        if right < n {
            workingBars[right].state = .comparing
            publishIfNeeded()
            await delay(Int(speed / 2))
            
            // Play comparison sound
            playComparisonSound(value1: workingBars[right].value, value2: workingBars[target].value)
            
            // For ascending: build max heap; for descending: build min heap
            let shouldUpdate = sortDirection == .ascending ?
                workingBars[right].value > workingBars[target].value :
                workingBars[right].value < workingBars[target].value
            
            if shouldUpdate {
                target = right
            }
            workingBars[right].state = .unsorted
            publishIfNeeded()
        }
        
        if target != root {
            workingBars[root].state = .comparing
            workingBars[target].state = .comparing
            publishIfNeeded()
            await swapBars(at: root, and: target)
            workingBars[root].state = .unsorted
            workingBars[target].state = .unsorted
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
                publishIfNeeded()
                var j = i
                
                while j >= gap && shouldSwap(workingBars[j - gap].value, temp.value) {
                    guard !Task.isCancelled else { break }
                    
                    workingBars[j - gap].state = .comparing
                    workingBars[j].state = .comparing
                    publishIfNeeded()
                    
                    // Play comparison sound
                    playComparisonSound(value1: workingBars[j - gap].value, value2: temp.value)
                    
                    await swapBars(at: j, and: j - gap)
                    
                    workingBars[j].state = .unsorted
                    publishIfNeeded()
                    j -= gap
                }
                
                workingBars[j].state = .unsorted
                publishIfNeeded()
            }
            
            gap /= 2
        }
        
        // Ensure all bars are marked as sorted
        for index in workingBars.indices {
            workingBars[index].state = .sorted
        }
        publishNow()
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
        
        // Now replace entire array and animate the result
        workingBars = sortDirection == .ascending ? output : output.reversed()
        
        // Set all bars to sorted state (skip individual animation to avoid throttling issues)
        for index in workingBars.indices {
            workingBars[index].state = .sorted
        }
        publishNow()
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
                
                workingBars[i].state = .comparing
                workingBars[i + 1].state = .comparing
                publishIfNeeded()
                
                // Play comparison sound
                playComparisonSound(value1: workingBars[i].value, value2: workingBars[i + 1].value)
                
                if shouldSwap(workingBars[i].value, workingBars[i + 1].value) {
                    await swapBars(at: i, and: i + 1)
                    swapped = true
                }
                
                workingBars[i].state = .unsorted
                workingBars[i + 1].state = .unsorted
                publishIfNeeded()
            }
            
            if !swapped {
                break
            }
            
            workingBars[end].state = .sorted
            publishIfNeeded()
            end -= 1
            swapped = false
            
            // Backward pass (right to left)
            for i in stride(from: end, through: start, by: -1) {
                guard !Task.isCancelled else { break }
                
                workingBars[i].state = .comparing
                workingBars[i + 1].state = .comparing
                publishIfNeeded()
                
                // Play comparison sound
                playComparisonSound(value1: workingBars[i].value, value2: workingBars[i + 1].value)
                
                if shouldSwap(workingBars[i].value, workingBars[i + 1].value) {
                    await swapBars(at: i, and: i + 1)
                    swapped = true
                }
                
                workingBars[i].state = .unsorted
                workingBars[i + 1].state = .unsorted
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
