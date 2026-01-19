//
//  SortingAlgorithms.swift
//  SortAnimation
//
//  Pure sorting algorithm implementations without UI dependencies.
//  These functions can be unit tested independently.
//

import Foundation

/// Direction for sorting
enum SortOrder {
    case ascending
    case descending
}

/// Pure sorting algorithms that operate on arrays of Comparable elements
struct SortingAlgorithms {
    
    // MARK: - Bubble Sort
    
    static func bubbleSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        let n = result.count
        
        for i in 0..<n {
            var swapped = false
            for j in 0..<(n - i - 1) {
                let shouldSwap = order == .ascending ? 
                    result[j] > result[j + 1] : 
                    result[j] < result[j + 1]
                
                if shouldSwap {
                    result.swapAt(j, j + 1)
                    swapped = true
                }
            }
            if !swapped { break }
        }
        
        return result
    }
    
    // MARK: - Selection Sort
    
    static func selectionSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        let n = result.count
        
        for i in 0..<n {
            var targetIndex = i
            
            for j in (i + 1)..<n {
                let shouldUpdate = order == .ascending ?
                    result[j] < result[targetIndex] :
                    result[j] > result[targetIndex]
                
                if shouldUpdate {
                    targetIndex = j
                }
            }
            
            if targetIndex != i {
                result.swapAt(i, targetIndex)
            }
        }
        
        return result
    }
    
    // MARK: - Insertion Sort
    
    static func insertionSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        let n = result.count
        
        for i in 1..<n {
            let key = result[i]
            var j = i - 1
            
            while j >= 0 {
                let shouldMove = order == .ascending ?
                    result[j] > key :
                    result[j] < key
                
                if shouldMove {
                    result[j + 1] = result[j]
                    j -= 1
                } else {
                    break
                }
            }
            
            result[j + 1] = key
        }
        
        return result
    }
    
    // MARK: - Quick Sort
    
    static func quickSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        quickSortHelper(&result, low: 0, high: result.count - 1, order: order)
        return result
    }
    
    private static func quickSortHelper<T: Comparable>(_ array: inout [T], low: Int, high: Int, order: SortOrder) {
        guard low < high else { return }
        
        let pivotIndex = partition(&array, low: low, high: high, order: order)
        quickSortHelper(&array, low: low, high: pivotIndex - 1, order: order)
        quickSortHelper(&array, low: pivotIndex + 1, high: high, order: order)
    }
    
    private static func partition<T: Comparable>(_ array: inout [T], low: Int, high: Int, order: SortOrder) -> Int {
        let pivot = array[high]
        var i = low - 1
        
        for j in low..<high {
            let shouldSwap = order == .ascending ?
                array[j] < pivot :
                array[j] > pivot
            
            if shouldSwap {
                i += 1
                if i != j {
                    array.swapAt(i, j)
                }
            }
        }
        
        array.swapAt(i + 1, high)
        return i + 1
    }
    
    // MARK: - Merge Sort
    
    static func mergeSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        
        let mid = array.count / 2
        let left = mergeSort(Array(array[0..<mid]), order: order)
        let right = mergeSort(Array(array[mid..<array.count]), order: order)
        
        return merge(left, right, order: order)
    }
    
    private static func merge<T: Comparable>(_ left: [T], _ right: [T], order: SortOrder) -> [T] {
        var result: [T] = []
        result.reserveCapacity(left.count + right.count)
        
        var i = 0, j = 0
        
        while i < left.count && j < right.count {
            let shouldPickLeft = order == .ascending ?
                left[i] <= right[j] :
                left[i] >= right[j]
            
            if shouldPickLeft {
                result.append(left[i])
                i += 1
            } else {
                result.append(right[j])
                j += 1
            }
        }
        
        result.append(contentsOf: left[i..<left.count])
        result.append(contentsOf: right[j..<right.count])
        
        return result
    }
    
    // MARK: - Heap Sort
    
    static func heapSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        let n = result.count
        
        // Build heap
        for i in stride(from: n / 2 - 1, through: 0, by: -1) {
            heapify(&result, n: n, root: i, order: order)
        }
        
        // Extract elements from heap
        for i in stride(from: n - 1, through: 1, by: -1) {
            result.swapAt(0, i)
            heapify(&result, n: i, root: 0, order: order)
        }
        
        return result
    }
    
    private static func heapify<T: Comparable>(_ array: inout [T], n: Int, root: Int, order: SortOrder) {
        var largest = root
        let left = 2 * root + 1
        let right = 2 * root + 2
        
        if left < n {
            let shouldUpdate = order == .ascending ?
                array[left] > array[largest] :
                array[left] < array[largest]
            
            if shouldUpdate {
                largest = left
            }
        }
        
        if right < n {
            let shouldUpdate = order == .ascending ?
                array[right] > array[largest] :
                array[right] < array[largest]
            
            if shouldUpdate {
                largest = right
            }
        }
        
        if largest != root {
            array.swapAt(root, largest)
            heapify(&array, n: n, root: largest, order: order)
        }
    }
    
    // MARK: - Shell Sort
    
    static func shellSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        let n = result.count
        var gap = n / 2
        
        while gap > 0 {
            for i in gap..<n {
                let temp = result[i]
                var j = i
                
                while j >= gap {
                    let shouldSwap = order == .ascending ?
                        result[j - gap] > temp :
                        result[j - gap] < temp
                    
                    if shouldSwap {
                        result[j] = result[j - gap]
                        j -= gap
                    } else {
                        break
                    }
                }
                
                result[j] = temp
            }
            
            gap /= 2
        }
        
        return result
    }
    
    // MARK: - Cocktail Shaker Sort
    
    static func cocktailSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        var swapped = true
        var start = 0
        var end = result.count - 1
        
        while swapped {
            swapped = false
            
            // Forward pass
            for i in start..<end {
                let shouldSwap = order == .ascending ?
                    result[i] > result[i + 1] :
                    result[i] < result[i + 1]
                
                if shouldSwap {
                    result.swapAt(i, i + 1)
                    swapped = true
                }
            }
            
            if !swapped { break }
            
            end -= 1
            swapped = false
            
            // Backward pass
            for i in stride(from: end, through: start, by: -1) {
                let shouldSwap = order == .ascending ?
                    result[i] > result[i + 1] :
                    result[i] < result[i + 1]
                
                if shouldSwap {
                    result.swapAt(i, i + 1)
                    swapped = true
                }
            }
            
            start += 1
        }
        
        return result
    }
    
    // MARK: - Counting Sort (for integers only)
    
    static func countingSort(_ array: [Int], order: SortOrder = .ascending) -> [Int] {
        guard array.count > 1 else { return array }
        guard let maxValue = array.max(), let minValue = array.min() else { return array }
        
        let range = maxValue - minValue + 1
        var count = Array(repeating: 0, count: range)
        
        // Count occurrences
        for value in array {
            count[value - minValue] += 1
        }
        
        // Calculate cumulative count
        for i in 1..<range {
            count[i] += count[i - 1]
        }
        
        // Build output array
        var output = Array(repeating: 0, count: array.count)
        for i in stride(from: array.count - 1, through: 0, by: -1) {
            let index = array[i] - minValue
            output[count[index] - 1] = array[i]
            count[index] -= 1
        }
        
        return order == .ascending ? output : output.reversed()
    }
    
    // MARK: - Radix Sort (for non-negative integers only)
    
    static func radixSort(_ array: [Int], order: SortOrder = .ascending) -> [Int] {
        guard array.count > 1 else { return array }
        guard let maxValue = array.max(), maxValue >= 0 else { return array }
        
        var result = array
        var exp = 1
        
        while maxValue / exp > 0 {
            result = radixCountingSort(result, exp: exp)
            exp *= 10
        }
        
        return order == .ascending ? result : result.reversed()
    }
    
    private static func radixCountingSort(_ array: [Int], exp: Int) -> [Int] {
        let n = array.count
        var output = Array(repeating: 0, count: n)
        var count = Array(repeating: 0, count: 10)
        
        // Store count of occurrences
        for value in array {
            let digit = (value / exp) % 10
            count[digit] += 1
        }
        
        // Change count to actual position
        for i in 1..<10 {
            count[i] += count[i - 1]
        }
        
        // Build output array
        for i in stride(from: n - 1, through: 0, by: -1) {
            let digit = (array[i] / exp) % 10
            output[count[digit] - 1] = array[i]
            count[digit] -= 1
        }
        
        return output
    }
}
