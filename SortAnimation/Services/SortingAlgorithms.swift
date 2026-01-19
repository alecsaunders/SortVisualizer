//
//  SortingAlgorithms.swift
//  SortAnimation
//
//  Pure sorting algorithm implementations without UI dependencies.
//  These functions can be unit tested independently.
//

import Foundation

/// The order in which elements should be sorted.
enum SortOrder {
    /// Sort elements from smallest to largest
    case ascending
    
    /// Sort elements from largest to smallest
    case descending
}

/// Pure sorting algorithm implementations that operate on arrays of comparable elements.
///
/// All sorting functions are:
/// - **Pure**: No side effects, return new sorted arrays
/// - **Generic**: Work with any `Comparable` type
/// - **Testable**: No UI dependencies, easy to unit test
///
/// ## Topics
///
/// ### Comparison Sorts
/// - ``bubbleSort(_:order:)``
/// - ``selectionSort(_:order:)``
/// - ``insertionSort(_:order:)``
/// - ``quickSort(_:order:)``
/// - ``mergeSort(_:order:)``
/// - ``heapSort(_:order:)``
/// - ``shellSort(_:order:)``
/// - ``cocktailSort(_:order:)``
///
/// ### Non-Comparison Sorts
/// - ``countingSort(_:order:)``
/// - ``radixSort(_:order:)``
struct SortingAlgorithms {
    
    // MARK: - Bubble Sort
    
    /// Sorts an array using the bubble sort algorithm.
    ///
    /// Bubble sort repeatedly steps through the list, compares adjacent elements,
    /// and swaps them if they're in the wrong order. The pass through the list is repeated
    /// until the list is sorted.
    ///
    /// - Complexity:
    ///   - Time: O(n²) worst and average case, O(n) best case (already sorted)
    ///   - Space: O(1)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This algorithm is stable and adaptive (faster on nearly-sorted data).
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
    
    /// Sorts an array using the selection sort algorithm.
    ///
    /// Selection sort divides the input into a sorted and an unsorted region.
    /// It repeatedly selects the smallest (or largest) element from the unsorted region
    /// and moves it to the end of the sorted region.
    ///
    /// - Complexity:
    ///   - Time: O(n²) in all cases
    ///   - Space: O(1)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This algorithm is not stable but performs well with minimal swaps.
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
    
    /// Sorts an array using the insertion sort algorithm.
    ///
    /// Insertion sort builds the final sorted array one item at a time by repeatedly
    /// inserting a new element into the sorted portion of the array.
    ///
    /// - Complexity:
    ///   - Time: O(n²) worst case, O(n) best case (already sorted)
    ///   - Space: O(1)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This algorithm is stable and efficient for small or nearly-sorted datasets.
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
    
    /// Sorts an array using the quick sort algorithm.
    ///
    /// Quick sort is a divide-and-conquer algorithm that selects a 'pivot' element
    /// and partitions the array around it, then recursively sorts the sub-arrays.
    ///
    /// - Complexity:
    ///   - Time: O(n log n) average case, O(n²) worst case
    ///   - Space: O(log n) due to recursion
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This implementation uses the last element as the pivot.
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
    
    /// Sorts an array using the merge sort algorithm.
    ///
    /// Merge sort is a divide-and-conquer algorithm that divides the array into halves,
    /// recursively sorts them, and then merges the sorted halves back together.
    ///
    /// - Complexity:
    ///   - Time: O(n log n) in all cases
    ///   - Space: O(n) for auxiliary arrays
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This algorithm is stable and guarantees O(n log n) performance.
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
    
    /// Sorts an array using the heap sort algorithm.
    ///
    /// Heap sort builds a binary heap from the input data, then repeatedly extracts
    /// the maximum element and rebuilds the heap until the array is sorted.
    ///
    /// - Complexity:
    ///   - Time: O(n log n) in all cases
    ///   - Space: O(1)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This algorithm is not stable but has consistent O(n log n) performance.
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
    
    /// Sorts an array using the shell sort algorithm.
    ///
    /// Shell sort is a generalization of insertion sort that allows the exchange of items
    /// that are far apart. The algorithm uses a sequence of decreasing gap values to sort
    /// sub-arrays before performing a final insertion sort.
    ///
    /// - Complexity:
    ///   - Time: O(n log n) to O(n²) depending on gap sequence
    ///   - Space: O(1)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This implementation uses a simple gap sequence (n/2, n/4, ..., 1).
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
    
    /// Sorts an array using the cocktail shaker sort algorithm.
    ///
    /// Cocktail shaker sort (also known as bidirectional bubble sort) is a variation of
    /// bubble sort that sorts in both directions on each pass through the list.
    ///
    /// - Complexity:
    ///   - Time: O(n²) worst case, O(n) best case
    ///   - Space: O(1)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This algorithm is stable and slightly more efficient than bubble sort on some inputs.
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
    
    /// Sorts an integer array using the counting sort algorithm.
    ///
    /// Counting sort is a non-comparison based sorting algorithm that counts the occurrences
    /// of each distinct element, then uses arithmetic to calculate the position of each element
    /// in the output sequence.
    ///
    /// - Complexity:
    ///   - Time: O(n + k) where k is the range of input values
    ///   - Space: O(k) for the counting array
    ///
    /// - Parameters:
    ///   - array: The integer array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: Most efficient when the range of input values is not significantly greater than n.
    ///         This algorithm is stable.
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
    
    /// Sorts a non-negative integer array using the radix sort algorithm.
    ///
    /// Radix sort is a non-comparison based sorting algorithm that sorts integers by processing
    /// individual digits. It uses counting sort as a subroutine to sort the array digit by digit.
    ///
    /// - Complexity:
    ///   - Time: O(d × (n + k)) where d is the number of digits and k is the base (10)
    ///   - Space: O(n + k)
    ///
    /// - Parameters:
    ///   - array: The non-negative integer array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: Most efficient for large datasets with a limited number of digits.
    ///         Requires non-negative integers.
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
