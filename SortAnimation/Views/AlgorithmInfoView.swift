//
//  AlgorithmInfoView.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import SwiftUI

struct AlgorithmInfoView: View {
    let algorithm: SortAlgorithm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(algorithm.rawValue)
                .font(.title2)
                .fontWeight(.semibold)
            
            Divider()
            
            // Complexity
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Time Complexity:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(algorithmInfo.timeComplexity)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                }
                
                HStack {
                    Text("Space Complexity:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(algorithmInfo.spaceComplexity)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                }
                
                HStack {
                    Text("Stable:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(algorithmInfo.stable ? "Yes" : "No")
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Description
            VStack(alignment: .leading, spacing: 6) {
                Text("How it works:")
                    .fontWeight(.medium)
                
                Text(algorithmInfo.description)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    private var algorithmInfo: AlgorithmInfo {
        switch algorithm {
        case .bubble:
            return AlgorithmInfo(
                timeComplexity: "O(n²)",
                spaceComplexity: "O(1)",
                stable: true,
                description: "Repeatedly steps through the list, compares adjacent elements, and swaps them if they're in the wrong order. The pass is repeated until the list is sorted. Larger elements \"bubble up\" to the end."
            )
            
        case .selection:
            return AlgorithmInfo(
                timeComplexity: "O(n²)",
                spaceComplexity: "O(1)",
                stable: false,
                description: "Divides the list into sorted and unsorted regions. Repeatedly finds the minimum element from the unsorted region and moves it to the end of the sorted region."
            )
            
        case .insertion:
            return AlgorithmInfo(
                timeComplexity: "O(n²)",
                spaceComplexity: "O(1)",
                stable: true,
                description: "Builds the sorted array one element at a time. Takes each element and inserts it into its correct position in the already-sorted portion, shifting elements as needed."
            )
            
        case .merge:
            return AlgorithmInfo(
                timeComplexity: "O(n log n)",
                spaceComplexity: "O(n)",
                stable: true,
                description: "Divide and conquer algorithm that divides the array into halves, recursively sorts them, then merges the sorted halves back together in order."
            )
            
        case .quick:
            return AlgorithmInfo(
                timeComplexity: "O(n log n) avg, O(n²) worst",
                spaceComplexity: "O(log n)",
                stable: false,
                description: "Selects a pivot element and partitions the array so elements smaller than the pivot come before it and larger elements come after. Recursively applies this to the subarrays."
            )
            
        case .heap:
            return AlgorithmInfo(
                timeComplexity: "O(n log n)",
                spaceComplexity: "O(1)",
                stable: false,
                description: "Builds a max heap from the array, then repeatedly extracts the maximum element and places it at the end. Uses heapify operations to maintain the heap property."
            )
            
        case .shell:
            return AlgorithmInfo(
                timeComplexity: "O(n log n) to O(n²)",
                spaceComplexity: "O(1)",
                stable: false,
                description: "Generalization of insertion sort that allows exchange of elements that are far apart. Starts with large gaps between compared elements and progressively reduces the gap."
            )
            
        case .cocktail:
            return AlgorithmInfo(
                timeComplexity: "O(n²)",
                spaceComplexity: "O(1)",
                stable: true,
                description: "Variation of bubble sort that sorts in both directions alternately. Each pass goes forward and then backward, which can be more efficient than standard bubble sort."
            )
            
        case .counting:
            return AlgorithmInfo(
                timeComplexity: "O(n + k)",
                spaceComplexity: "O(k)",
                stable: true,
                description: "Non-comparison algorithm that counts the number of occurrences of each value, then uses arithmetic to determine positions. Works best when the range of values (k) is not significantly larger than the number of items (n)."
            )
            
        case .radix:
            return AlgorithmInfo(
                timeComplexity: "O(d × n)",
                spaceComplexity: "O(n + k)",
                stable: true,
                description: "Non-comparison algorithm that processes integers digit by digit, starting from the least significant digit. Uses counting sort as a subroutine for each digit position."
            )
            
        case .gnome:
            return AlgorithmInfo(
                timeComplexity: "O(n²)",
                spaceComplexity: "O(1)",
                stable: true,
                description: "Simple sorting algorithm similar to insertion sort. Like a garden gnome sorting flower pots, it moves forward if the current element is in order, or swaps and moves backward if not."
            )
            
        case .comb:
            return AlgorithmInfo(
                timeComplexity: "O(n²) worst, O(n log n) avg",
                spaceComplexity: "O(1)",
                stable: false,
                description: "Improved bubble sort that eliminates small values near the end (turtles) by using gap sequences. Starts with large gaps and shrinks by a factor of 1.3 until gap becomes 1."
            )
            
        case .cycle:
            return AlgorithmInfo(
                timeComplexity: "O(n²)",
                spaceComplexity: "O(1)",
                stable: false,
                description: "Minimizes the number of writes to the array by placing each element directly into its final position. Useful when write operations are expensive, such as with flash memory."
            )
            
        case .tim:
            return AlgorithmInfo(
                timeComplexity: "O(n log n)",
                spaceComplexity: "O(n)",
                stable: true,
                description: "Hybrid algorithm combining merge sort and insertion sort, used by Python and Java. Divides data into small runs, sorts them with insertion sort, then merges. Performs exceptionally well on real-world data."
            )
        }
    }
}

struct AlgorithmInfo {
    let timeComplexity: String
    let spaceComplexity: String
    let stable: Bool
    let description: String
}

#Preview {
    AlgorithmInfoView(algorithm: .quick)
}
