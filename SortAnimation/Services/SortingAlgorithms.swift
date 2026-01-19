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
/// - ``gnomeSort(_:order:)``
/// - ``combSort(_:order:)``
/// - ``cycleSort(_:order:)``
/// - ``timSort(_:order:)``
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
    
    // MARK: - Gnome Sort
    
    /// Sorts an array using the gnome sort algorithm.
    ///
    /// Gnome sort (also known as stupid sort) is similar to insertion sort but moves elements
    /// to their proper place by a series of swaps, like a garden gnome sorting flower pots.
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
    /// - Note: This algorithm is stable and very simple, but inefficient for large arrays.
    static func gnomeSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        var index = 0
        
        while index < result.count {
            if index == 0 {
                index += 1
            } else {
                let shouldSwap = order == .ascending ?
                    result[index] < result[index - 1] :
                    result[index] > result[index - 1]
                
                if shouldSwap {
                    result.swapAt(index, index - 1)
                    index -= 1
                } else {
                    index += 1
                }
            }
        }
        
        return result
    }
    
    // MARK: - Comb Sort
    
    /// Sorts an array using the comb sort algorithm.
    ///
    /// Comb sort improves on bubble sort by using gap sequences larger than 1.
    /// It eliminates small values near the end of the list (turtles) that slow down bubble sort.
    ///
    /// - Complexity:
    ///   - Time: O(n²) worst case, O(n log n) average case
    ///   - Space: O(1)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: Uses a shrink factor of 1.3 for the gap sequence, which is empirically optimal.
    static func combSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        var gap = result.count
        let shrink: Double = 1.3
        var sorted = false
        
        while !sorted {
            // Update gap value
            gap = Int(Double(gap) / shrink)
            if gap <= 1 {
                gap = 1
                sorted = true
            }
            
            // Compare all elements with current gap
            var i = 0
            while i + gap < result.count {
                let shouldSwap = order == .ascending ?
                    result[i] > result[i + gap] :
                    result[i] < result[i + gap]
                
                if shouldSwap {
                    result.swapAt(i, i + gap)
                    sorted = false
                }
                i += 1
            }
        }
        
        return result
    }
    
    // MARK: - Cycle Sort
    
    /// Sorts an array using the cycle sort algorithm.
    ///
    /// Cycle sort is an in-place, unstable sorting algorithm that minimizes the number of writes
    /// to the original array. It's useful when write operations are significantly more expensive
    /// than reads.
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
    /// - Note: Minimizes writes to memory, making it useful for flash memory or EEPROM.
    static func cycleSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        var result = array
        let n = result.count
        
        // Loop through the array to find cycles
        for cycleStart in 0..<(n - 1) {
            var item = result[cycleStart]
            
            // Find position where we put the item
            var pos = cycleStart
            for i in (cycleStart + 1)..<n {
                let shouldCount = order == .ascending ?
                    result[i] < item :
                    result[i] > item
                
                if shouldCount {
                    pos += 1
                }
            }
            
            // If item is already in correct position
            if pos == cycleStart {
                continue
            }
            
            // Skip duplicates
            while item == result[pos] {
                pos += 1
            }
            
            // Put the item to its right position
            if pos != cycleStart {
                swap(&item, &result[pos])
            }
            
            // Rotate rest of the cycle
            while pos != cycleStart {
                pos = cycleStart
                
                // Find position where we put the element
                for i in (cycleStart + 1)..<n {
                    let shouldCount = order == .ascending ?
                        result[i] < item :
                        result[i] > item
                    
                    if shouldCount {
                        pos += 1
                    }
                }
                
                // Skip duplicates
                while item == result[pos] {
                    pos += 1
                }
                
                // Put the item to its right position
                if item != result[pos] {
                    swap(&item, &result[pos])
                }
            }
        }
        
        return result
    }
    
    // MARK: - Tim Sort
    
    /// Sorts an array using the Tim sort algorithm.
    ///
    /// Tim sort is a hybrid stable sorting algorithm derived from merge sort and insertion sort.
    /// It's designed to perform well on many kinds of real-world data. It's the default sorting
    /// algorithm in Python and Java.
    ///
    /// - Complexity:
    ///   - Time: O(n log n) worst case, O(n) best case
    ///   - Space: O(n)
    ///
    /// - Parameters:
    ///   - array: The array to sort
    ///   - order: The sort direction (ascending or descending)
    /// - Returns: A new sorted array
    ///
    /// - Note: This algorithm is stable and adapts to partially sorted data.
    static func timSort<T: Comparable>(_ array: [T], order: SortOrder = .ascending) -> [T] {
        guard array.count > 1 else { return array }
        
        let minRun = 32
        var result = array
        let n = result.count
        
        // Sort individual runs using insertion sort
        var start = 0
        while start < n {
            let end = min(start + minRun - 1, n - 1)
            result = timInsertionSort(result, left: start, right: end, order: order)
            start += minRun
        }
        
        // Merge sorted runs
        var size = minRun
        while size < n {
            var left = 0
            while left < n {
                let mid = left + size - 1
                let right = min(left + size * 2 - 1, n - 1)
                
                if mid < right {
                    result = timMerge(result, left: left, mid: mid, right: right, order: order)
                }
                
                left += size * 2
            }
            size *= 2
        }
        
        return result
    }
    
    private static func timInsertionSort<T: Comparable>(_ array: [T], left: Int, right: Int, order: SortOrder) -> [T] {
        var result = array
        
        for i in (left + 1)...right {
            let key = result[i]
            var j = i - 1
            
            while j >= left {
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
    
    private static func timMerge<T: Comparable>(_ array: [T], left: Int, mid: Int, right: Int, order: SortOrder) -> [T] {
        var result = array
        
        let leftArray = Array(result[left...mid])
        let rightArray = Array(result[(mid + 1)...right])
        
        var i = 0, j = 0, k = left
        
        while i < leftArray.count && j < rightArray.count {
            let shouldPickLeft = order == .ascending ?
                leftArray[i] <= rightArray[j] :
                leftArray[i] >= rightArray[j]
            
            if shouldPickLeft {
                result[k] = leftArray[i]
                i += 1
            } else {
                result[k] = rightArray[j]
                j += 1
            }
            k += 1
        }
        
        while i < leftArray.count {
            result[k] = leftArray[i]
            i += 1
            k += 1
        }
        
        while j < rightArray.count {
            result[k] = rightArray[j]
            j += 1
            k += 1
        }
        
        return result
    }
}
