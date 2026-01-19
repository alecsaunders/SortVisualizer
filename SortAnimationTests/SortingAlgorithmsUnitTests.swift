//
//  SortingAlgorithmsUnitTests.swift
//  SortAnimationTests
//
//  Pure unit tests for sorting algorithms without UI dependencies.
//

import Testing
@testable import SortAnimation

struct SortingAlgorithmsUnitTests {
    
    // MARK: - Test Data
    
    private let unsortedArray = [64, 34, 25, 12, 22, 11, 90, 88, 45, 50, 33, 17, 28, 19, 61]
    private let sortedAscending = [11, 12, 17, 19, 22, 25, 28, 33, 34, 45, 50, 61, 64, 88, 90]
    private let sortedDescending = [90, 88, 64, 61, 50, 45, 34, 33, 28, 25, 22, 19, 17, 12, 11]
    private let alreadySorted = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    private let reverseSorted = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    private let duplicates = [5, 2, 8, 2, 9, 1, 5, 5, 3, 2]
    private let duplicatesSorted = [1, 2, 2, 2, 3, 5, 5, 5, 8, 9]
    
    // MARK: - Bubble Sort Tests
    
    @Test func bubbleSortAscending() {
        let result = SortingAlgorithms.bubbleSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func bubbleSortDescending() {
        let result = SortingAlgorithms.bubbleSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func bubbleSortAlreadySorted() {
        let result = SortingAlgorithms.bubbleSort(alreadySorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func bubbleSortWithDuplicates() {
        let result = SortingAlgorithms.bubbleSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Selection Sort Tests
    
    @Test func selectionSortAscending() {
        let result = SortingAlgorithms.selectionSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func selectionSortDescending() {
        let result = SortingAlgorithms.selectionSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func selectionSortReverseSorted() {
        let result = SortingAlgorithms.selectionSort(reverseSorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    // MARK: - Insertion Sort Tests
    
    @Test func insertionSortAscending() {
        let result = SortingAlgorithms.insertionSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func insertionSortDescending() {
        let result = SortingAlgorithms.insertionSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func insertionSortWithDuplicates() {
        let result = SortingAlgorithms.insertionSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Quick Sort Tests
    
    @Test func quickSortAscending() {
        let result = SortingAlgorithms.quickSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func quickSortDescending() {
        let result = SortingAlgorithms.quickSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func quickSortAlreadySorted() {
        let result = SortingAlgorithms.quickSort(alreadySorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func quickSortWithDuplicates() {
        let result = SortingAlgorithms.quickSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Merge Sort Tests
    
    @Test func mergeSortAscending() {
        let result = SortingAlgorithms.mergeSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func mergeSortDescending() {
        let result = SortingAlgorithms.mergeSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func mergeSortReverseSorted() {
        let result = SortingAlgorithms.mergeSort(reverseSorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func mergeSortWithDuplicates() {
        let result = SortingAlgorithms.mergeSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Heap Sort Tests
    
    @Test func heapSortAscending() {
        let result = SortingAlgorithms.heapSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func heapSortDescending() {
        let result = SortingAlgorithms.heapSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func heapSortAlreadySorted() {
        let result = SortingAlgorithms.heapSort(alreadySorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    // MARK: - Shell Sort Tests
    
    @Test func shellSortAscending() {
        let result = SortingAlgorithms.shellSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func shellSortDescending() {
        let result = SortingAlgorithms.shellSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func shellSortWithDuplicates() {
        let result = SortingAlgorithms.shellSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Cocktail Sort Tests
    
    @Test func cocktailSortAscending() {
        let result = SortingAlgorithms.cocktailSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func cocktailSortDescending() {
        let result = SortingAlgorithms.cocktailSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func cocktailSortReverseSorted() {
        let result = SortingAlgorithms.cocktailSort(reverseSorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    // MARK: - Counting Sort Tests
    
    @Test func countingSortAscending() {
        let result = SortingAlgorithms.countingSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func countingSortDescending() {
        let result = SortingAlgorithms.countingSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func countingSortWithDuplicates() {
        let result = SortingAlgorithms.countingSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Radix Sort Tests
    
    @Test func radixSortAscending() {
        let result = SortingAlgorithms.radixSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func radixSortDescending() {
        let result = SortingAlgorithms.radixSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func radixSortAlreadySorted() {
        let result = SortingAlgorithms.radixSort(alreadySorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    // MARK: - Edge Cases
    
    @Test func emptyArrayBubbleSort() {
        let empty: [Int] = []
        let result = SortingAlgorithms.bubbleSort(empty)
        #expect(result.isEmpty)
    }
    
    @Test func singleElementBubbleSort() {
        let single = [42]
        let result = SortingAlgorithms.bubbleSort(single)
        #expect(result == single)
    }
    
    @Test func twoElementsQuickSort() {
        let two = [2, 1]
        let result = SortingAlgorithms.quickSort(two)
        #expect(result == [1, 2])
    }
    
    @Test func allSameValuesMergeSort() {
        let same = [5, 5, 5, 5, 5]
        let result = SortingAlgorithms.mergeSort(same)
        #expect(result == same)
    }
    
    @Test func largeArrayQuickSort() {
        let large = Array((1...100).shuffled())
        let result = SortingAlgorithms.quickSort(large)
        #expect(result == Array(1...100))
    }
    
    // MARK: - String Sorting Tests
    
    @Test func stringSortingBubble() {
        let words = ["zebra", "apple", "mango", "banana", "cherry"]
        let result = SortingAlgorithms.bubbleSort(words, order: .ascending)
        #expect(result == ["apple", "banana", "cherry", "mango", "zebra"])
    }
    
    @Test func stringSortingMerge() {
        let words = ["zebra", "apple", "mango", "banana", "cherry"]
        let result = SortingAlgorithms.mergeSort(words, order: .descending)
        #expect(result == ["zebra", "mango", "cherry", "banana", "apple"])
    }
    
    // MARK: - Performance Characteristics
    
    @Test func bubbleSortStopsEarlyWhenSorted() {
        // Bubble sort should detect no swaps and exit early
        let nearSorted = [1, 2, 3, 5, 4, 6, 7, 8, 9, 10]
        let result = SortingAlgorithms.bubbleSort(nearSorted)
        #expect(result == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
    
    @Test func cocktailSortBidirectional() {
        // Cocktail sort should handle this efficiently
        let array = [3, 1, 2, 5, 4]
        let result = SortingAlgorithms.cocktailSort(array)
        #expect(result == [1, 2, 3, 4, 5])
    }
    
    // MARK: - Gnome Sort Tests
    
    @Test func gnomeSortAscending() {
        let result = SortingAlgorithms.gnomeSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func gnomeSortDescending() {
        let result = SortingAlgorithms.gnomeSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func gnomeSortAlreadySorted() {
        let result = SortingAlgorithms.gnomeSort(alreadySorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func gnomeSortWithDuplicates() {
        let result = SortingAlgorithms.gnomeSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Comb Sort Tests
    
    @Test func combSortAscending() {
        let result = SortingAlgorithms.combSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func combSortDescending() {
        let result = SortingAlgorithms.combSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func combSortReverseSorted() {
        let result = SortingAlgorithms.combSort(reverseSorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func combSortWithDuplicates() {
        let result = SortingAlgorithms.combSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Cycle Sort Tests
    
    @Test func cycleSortAscending() {
        let result = SortingAlgorithms.cycleSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func cycleSortDescending() {
        let result = SortingAlgorithms.cycleSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func cycleSortAlreadySorted() {
        let result = SortingAlgorithms.cycleSort(alreadySorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func cycleSortWithDuplicates() {
        let result = SortingAlgorithms.cycleSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    // MARK: - Tim Sort Tests
    
    @Test func timSortAscending() {
        let result = SortingAlgorithms.timSort(unsortedArray, order: .ascending)
        #expect(result == sortedAscending)
    }
    
    @Test func timSortDescending() {
        let result = SortingAlgorithms.timSort(unsortedArray, order: .descending)
        #expect(result == sortedDescending)
    }
    
    @Test func timSortAlreadySorted() {
        let result = SortingAlgorithms.timSort(alreadySorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func timSortReverseSorted() {
        let result = SortingAlgorithms.timSort(reverseSorted, order: .ascending)
        #expect(result == alreadySorted)
    }
    
    @Test func timSortWithDuplicates() {
        let result = SortingAlgorithms.timSort(duplicates, order: .ascending)
        #expect(result == duplicatesSorted)
    }
    
    @Test func timSortLargeArray() {
        let large = Array((1...100).shuffled())
        let result = SortingAlgorithms.timSort(large)
        #expect(result == Array(1...100))
    }
    
    // MARK: - New Algorithms Edge Cases
    
    @Test func gnomeSortEmpty() {
        let empty: [Int] = []
        let result = SortingAlgorithms.gnomeSort(empty)
        #expect(result.isEmpty)
    }
    
    @Test func combSortSingleElement() {
        let single = [42]
        let result = SortingAlgorithms.combSort(single)
        #expect(result == single)
    }
    
    @Test func cycleSortTwoElements() {
        let two = [2, 1]
        let result = SortingAlgorithms.cycleSort(two)
        #expect(result == [1, 2])
    }
    
    @Test func timSortAllSame() {
        let same = [7, 7, 7, 7, 7, 7]
        let result = SortingAlgorithms.timSort(same)
        #expect(result == same)
    }
    
    // MARK: - String Sorting with New Algorithms
    
    @Test func stringSortingGnome() {
        let words = ["dog", "cat", "bird", "ant"]
        let result = SortingAlgorithms.gnomeSort(words, order: .ascending)
        #expect(result == ["ant", "bird", "cat", "dog"])
    }
    
    @Test func stringSortingComb() {
        let words = ["zebra", "apple", "mango"]
        let result = SortingAlgorithms.combSort(words, order: .descending)
        #expect(result == ["zebra", "mango", "apple"])
    }
    
    @Test func stringSortingCycle() {
        let words = ["xyz", "abc", "def", "mno"]
        let result = SortingAlgorithms.cycleSort(words, order: .ascending)
        #expect(result == ["abc", "def", "mno", "xyz"])
    }
    
    @Test func stringSortingTim() {
        let words = ["orange", "apple", "banana", "cherry", "date"]
        let result = SortingAlgorithms.timSort(words, order: .ascending)
        #expect(result == ["apple", "banana", "cherry", "date", "orange"])
    }
}
