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
        
        let values = Array(1...numberOfElements).shuffled()
        bars.removeAll(keepingCapacity: true) // Keep capacity for reuse
        bars.reserveCapacity(numberOfElements) // Ensure capacity
        bars = values.map { Bar(value: $0, state: .unsorted) }
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
        
        sortTask = Task {
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
            
            if !Task.isCancelled {
                // Mark all as sorted
                for index in bars.indices {
                    bars[index].state = .sorted
                }
                isSorting = false
            }
        }
    }
    
    private func bubbleSort() async {
        let n = bars.count
        
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            
            var swapped = false
            for j in 0..<(n - i - 1) {
                guard !Task.isCancelled else { break }
                
                // Mark bars being compared
                bars[j].state = .comparing
                bars[j + 1].state = .comparing
                
                // Play comparison sound
                playComparisonSound(value1: bars[j].value, value2: bars[j + 1].value)
                
                if shouldSwap(bars[j].value, bars[j + 1].value) {
                    // Perform swap with animation
                    await swapBars(at: j, and: j + 1)
                    swapped = true
                }
                
                // Reset state after comparison
                if bars[j].state == .comparing {
                    bars[j].state = .unsorted
                }
                if bars[j + 1].state == .comparing {
                    bars[j + 1].state = .unsorted
                }
            }
            
            // Mark the last element of this pass as sorted
            if i < n {
                bars[n - i - 1].state = .sorted
            }
            
            if !swapped {
                break
            }
        }
    }
    
    private func selectionSort() async {
        let n = bars.count
        
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            
            var targetIndex = i
            bars[targetIndex].state = .comparing
            
            for j in (i + 1)..<n {
                guard !Task.isCancelled else { break }
                
                bars[j].state = .comparing
                
                // Small delay to visualize comparison
                await delay(Int(speed / 2))
                
                // Play comparison sound
                playComparisonSound(value1: bars[j].value, value2: bars[targetIndex].value)
                
                // For ascending: find minimum; for descending: find maximum
                let shouldUpdate = sortDirection == .ascending ? 
                    bars[j].value < bars[targetIndex].value : 
                    bars[j].value > bars[targetIndex].value
                
                if shouldUpdate {
                    // Reset previous target
                    if bars[targetIndex].state == .comparing {
                        bars[targetIndex].state = .unsorted
                    }
                    targetIndex = j
                    bars[targetIndex].state = .comparing
                } else {
                    // Reset if not the target
                    if bars[j].state == .comparing && j != targetIndex {
                        bars[j].state = .unsorted
                    }
                }
            }
            
            if targetIndex != i {
                await swapBars(at: i, and: targetIndex)
            } else {
                // No swap needed, just mark as sorted
                bars[i].state = .sorted
            }
            
            // Mark the position as sorted
            bars[i].state = .sorted
        }
    }
    
    @MainActor
    private func swapBars(at index1: Int, and index2: Int) async {
        guard index1 != index2, index1 >= 0, index2 >= 0, 
              index1 < bars.count, index2 < bars.count else { return }
        
        // Calculate the distance between bars
        let distance = CGFloat(abs(index2 - index1))
        
        // Set offsets for animation
        if index1 < index2 {
            bars[index1].offset = distance
            bars[index2].offset = -distance
        } else {
            bars[index1].offset = -distance
            bars[index2].offset = distance
        }
        
        // Animate the swap
        withAnimation(.linear(duration: speed / 1000.0)) {
            bars[index1].offset = bars[index1].offset
            bars[index2].offset = bars[index2].offset
        }
        
        // Wait for animation plus speed delay
        await delay(Int(speed))
        
        // Actually swap the bars
        bars.swapAt(index1, index2)
        
        // Reset offsets
        bars[index1].offset = 0
        bars[index2].offset = 0
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
        soundGenerator.playComparison(
            value1: value1,
            value2: value2,
            maxValue: numberOfElements,
            duration: min(Double(speed) / 1000.0, 0.2)
        )
    }
    
    private func insertionSort() async {
        let n = bars.count
        
        for i in 1..<n {
            guard !Task.isCancelled else { break }
            
            let key = bars[i]
            bars[i].state = .comparing
            var j = i - 1
            
            // Find the correct position for the key
            while j >= 0 && shouldSwap(bars[j].value, key.value) {
                guard !Task.isCancelled else { break }
                
                bars[j].state = .comparing
                bars[j + 1].state = .comparing
                
                // Play comparison sound
                playComparisonSound(value1: bars[j].value, value2: key.value)
                
                // Shift element to the right
                await swapBars(at: j, and: j + 1)
                
                bars[j + 1].state = .unsorted
                j -= 1
            }
            
            // Mark elements before current position as sorted
            for k in 0...i {
                if bars[k].state != .comparing {
                    bars[k].state = .unsorted
                }
            }
        }
    }
    
    private func mergeSort() async {
        await mergeSortHelper(start: 0, end: bars.count - 1)
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
        let leftArray = Array(bars[start...mid])
        let rightArray = Array(bars[(mid + 1)...end])
        
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
                bars[k] = leftArray[i]
                i += 1
            } else {
                bars[k] = rightArray[j]
                j += 1
            }
            
            bars[k].state = .comparing
            try? await Task.sleep(for: .milliseconds(Int(speed)))
            bars[k].state = .unsorted
            k += 1
        }
        
        // Copy remaining elements from left array
        while i < leftArray.count {
            guard !Task.isCancelled else { break }
            bars[k] = leftArray[i]
            bars[k].state = .comparing
            await delay(Int(speed))
            bars[k].state = .unsorted
            i += 1
            k += 1
        }
        
        // Copy remaining elements from right array
        while j < rightArray.count {
            guard !Task.isCancelled else { break }
            bars[k] = rightArray[j]
            bars[k].state = .comparing
            await delay(Int(speed))
            bars[k].state = .unsorted
            j += 1
            k += 1
        }
    }
    
    private func radixSort() async {
        guard !Task.isCancelled else { return }
        
        let maxValue = bars.max(by: { $0.value < $1.value })?.value ?? 0
        var exp = 1
        
        while maxValue / exp > 0 {
            guard !Task.isCancelled else { break }
            await countingSort(exp: exp)
            exp *= 10
        }
        
        // If descending, reverse the final result
        if sortDirection == .descending {
            bars = bars.reversed()
            // Animate the reversed result
            for i in 0..<bars.count {
                guard !Task.isCancelled else { break }
                bars[i].state = .comparing
                await delay(Int(speed))
                bars[i].state = .unsorted
            }
        }
    }
    
    private func countingSort(exp: Int) async {
        guard !Task.isCancelled else { return }
        
        let n = bars.count
        var output = [Bar]()
        output.reserveCapacity(n)
        output.append(contentsOf: repeatElement(Bar(value: 0), count: n))
        var count = Array(repeating: 0, count: 10)
        
        // Mark all bars as comparing during counting phase
        for i in 0..<n {
            bars[i].state = .comparing
        }
        await delay(Int(speed / 2))
        
        // Store count of occurrences
        for i in 0..<n {
            let digit = (bars[i].value / exp) % 10
            count[digit] += 1
        }
        
        // Change count[i] to contain actual position
        for i in 1..<10 {
            count[i] += count[i - 1]
        }
        
        // Build output array
        for i in stride(from: n - 1, through: 0, by: -1) {
            guard !Task.isCancelled else { break }
            
            let digit = (bars[i].value / exp) % 10
            output[count[digit] - 1] = bars[i]
            count[digit] -= 1
        }
        
        // Replace bars array with sorted output
        bars = output
        
        // Animate showing the result
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            bars[i].state = .comparing
            await delay(Int(speed))
            bars[i].state = .unsorted
        }
    }
    
    // MARK: - Quick Sort
    
    private func quickSort() async {
        await quickSortHelper(low: 0, high: bars.count - 1)
    }
    
    private func quickSortHelper(low: Int, high: Int) async {
        guard low < high, !Task.isCancelled else { return }
        
        let pivotIndex = await partition(low: low, high: high)
        
        await quickSortHelper(low: low, high: pivotIndex - 1)
        await quickSortHelper(low: pivotIndex + 1, high: high)
    }
    
    private func partition(low: Int, high: Int) async -> Int {
        guard !Task.isCancelled else { return low }
        
        let pivot = bars[high]
        bars[high].state = .comparing
        var i = low - 1
        
        for j in low..<high {
            guard !Task.isCancelled else { break }
            
            bars[j].state = .comparing
            await delay(Int(speed / 2))
            
            // Play comparison sound
            playComparisonSound(value1: bars[j].value, value2: pivot.value)
            
            // For ascending: elements < pivot go left; for descending: elements > pivot go left
            let shouldSwapToLeft = sortDirection == .ascending ?
                bars[j].value < pivot.value :
                bars[j].value > pivot.value
            
            if shouldSwapToLeft {
                i += 1
                if i != j {
                    await swapBars(at: i, and: j)
                }
            }
            
            if bars[j].state == .comparing {
                bars[j].state = .unsorted
            }
        }
        
        // Reset pivot state before swap
        bars[high].state = .unsorted
        
        await swapBars(at: i + 1, and: high)
        bars[i + 1].state = .sorted
        
        return i + 1
    }
    
    // MARK: - Heap Sort
    
    private func heapSort() async {
        let n = bars.count
        
        // Build max heap
        for i in stride(from: n / 2 - 1, through: 0, by: -1) {
            guard !Task.isCancelled else { break }
            await heapify(n: n, root: i)
        }
        
        // Extract elements from heap one by one
        for i in stride(from: n - 1, through: 1, by: -1) {
            guard !Task.isCancelled else { break }
            
            bars[0].state = .comparing
            bars[i].state = .comparing
            
            await swapBars(at: 0, and: i)
            bars[i].state = .sorted
            
            await heapify(n: i, root: 0)
        }
        
        if !Task.isCancelled && n > 0 {
            bars[0].state = .sorted
        }
    }
    
    private func heapify(n: Int, root: Int) async {
        guard !Task.isCancelled else { return }
        
        var target = root
        let left = 2 * root + 1
        let right = 2 * root + 2
        
        if left < n {
            bars[left].state = .comparing
            await delay(Int(speed / 2))
            
            // Play comparison sound
            playComparisonSound(value1: bars[left].value, value2: bars[target].value)
            
            // For ascending: build max heap; for descending: build min heap
            let shouldUpdate = sortDirection == .ascending ?
                bars[left].value > bars[target].value :
                bars[left].value < bars[target].value
            
            if shouldUpdate {
                target = left
            }
            bars[left].state = .unsorted
        }
        
        if right < n {
            bars[right].state = .comparing
            await delay(Int(speed / 2))
            
            // Play comparison sound
            playComparisonSound(value1: bars[right].value, value2: bars[target].value)
            
            // For ascending: build max heap; for descending: build min heap
            let shouldUpdate = sortDirection == .ascending ?
                bars[right].value > bars[target].value :
                bars[right].value < bars[target].value
            
            if shouldUpdate {
                target = right
            }
            bars[right].state = .unsorted
        }
        
        if target != root {
            bars[root].state = .comparing
            bars[target].state = .comparing
            await swapBars(at: root, and: target)
            bars[root].state = .unsorted
            bars[target].state = .unsorted
            
            await heapify(n: n, root: target)
        }
    }
    
    // MARK: - Shell Sort
    
    private func shellSort() async {
        let n = bars.count
        var gap = n / 2
        
        while gap > 0 {
            guard !Task.isCancelled else { break }
            
            for i in gap..<n {
                guard !Task.isCancelled else { break }
                
                let temp = bars[i]
                bars[i].state = .comparing
                var j = i
                
                while j >= gap && shouldSwap(bars[j - gap].value, temp.value) {
                    guard !Task.isCancelled else { break }
                    
                    bars[j - gap].state = .comparing
                    bars[j].state = .comparing
                    
                    // Play comparison sound
                    playComparisonSound(value1: bars[j - gap].value, value2: temp.value)
                    
                    await swapBars(at: j, and: j - gap)
                    
                    bars[j].state = .unsorted
                    j -= gap
                }
                
                bars[j].state = .unsorted
            }
            
            gap /= 2
        }
    }
    
    // MARK: - Counting Sort
    
    private func countingSort() async {
        guard !Task.isCancelled else { return }
        
        let n = bars.count
        let maxValue = bars.max(by: { $0.value < $1.value })?.value ?? 0
        let minValue = bars.min(by: { $0.value < $1.value })?.value ?? 0
        let range = maxValue - minValue + 1
        
        var count = Array(repeating: 0, count: range)
        
        // Store count of each element and mark as comparing
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            bars[i].state = .comparing
            count[bars[i].value - minValue] += 1
            await delay(Int(speed / 2))
        }
        
        // Build the sorted output array
        let originalBars = bars
        
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
        bars = sortDirection == .ascending ? output : output.reversed()
        
        // Animate through showing each bar in its sorted position
        for i in 0..<n {
            guard !Task.isCancelled else { break }
            
            bars[i].state = .comparing
            await delay(Int(speed))
            bars[i].state = .unsorted
        }
    }
    
    // MARK: - Cocktail Shaker Sort
    
    private func cocktailSort() async {
        var swapped = true
        var start = 0
        var end = bars.count - 1
        
        while swapped {
            guard !Task.isCancelled else { break }
            
            swapped = false
            
            // Forward pass (left to right)
            for i in start..<end {
                guard !Task.isCancelled else { break }
                
                bars[i].state = .comparing
                bars[i + 1].state = .comparing
                
                // Play comparison sound
                playComparisonSound(value1: bars[i].value, value2: bars[i + 1].value)
                
                if shouldSwap(bars[i].value, bars[i + 1].value) {
                    await swapBars(at: i, and: i + 1)
                    swapped = true
                }
                
                bars[i].state = .unsorted
                bars[i + 1].state = .unsorted
            }
            
            if !swapped {
                break
            }
            
            bars[end].state = .sorted
            end -= 1
            swapped = false
            
            // Backward pass (right to left)
            for i in stride(from: end, through: start, by: -1) {
                guard !Task.isCancelled else { break }
                
                bars[i].state = .comparing
                bars[i + 1].state = .comparing
                
                // Play comparison sound
                playComparisonSound(value1: bars[i].value, value2: bars[i + 1].value)
                
                if shouldSwap(bars[i].value, bars[i + 1].value) {
                    await swapBars(at: i, and: i + 1)
                    swapped = true
                }
                
                bars[i].state = .unsorted
                bars[i + 1].state = .unsorted
            }
            
            bars[start].state = .sorted
            start += 1
        }
        
        // Mark remaining unsorted as sorted
        for i in start...end {
            bars[i].state = .sorted
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
