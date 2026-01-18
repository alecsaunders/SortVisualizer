# SortAnimation

A high-performance macOS app built with SwiftUI that visualizes sorting algorithms with beautiful, smooth animations.

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features

- 🎨 **10 Sorting Algorithms** - Watch different algorithms in action
- ⚡ **High Performance** - Canvas-based rendering handles 200+ bars at 60fps
- 🎬 **Smooth Animations** - Horizontal bar crossing animations
- 🎛️ **Real-time Controls** - Adjust speed while sorting is running
- 🎨 **Color-coded States** - Blue (unsorted), Red (comparing), Green (sorted)
- 📊 **Scalable** - From 10 to 200 elements

## Supported Algorithms

### Comparison-Based Sorts
- **Bubble Sort** - O(n²) - Simple adjacent swapping
- **Selection Sort** - O(n²) - Finds minimum and places it
- **Insertion Sort** - O(n²) - Builds sorted array one element at a time
- **Quick Sort** - O(n log n) average - Divide and conquer with partitioning
- **Merge Sort** - O(n log n) - Divide and conquer with merging
- **Heap Sort** - O(n log n) - Binary heap-based sorting
- **Shell Sort** - O(n log n) to O(n²) - Improved insertion sort with gaps
- **Cocktail Shaker Sort** - O(n²) - Bidirectional bubble sort

### Non-Comparison Sorts
- **Counting Sort** - O(n + k) - Counts occurrences for integer sorting
- **Radix Sort** - O(d × n) - Digit-by-digit sorting

## Controls

| Control | Range | Description |
|---------|-------|-------------|
| **Algorithm** | 10 options | Select which sorting algorithm to visualize |
| **Speed** | 1-1000 ms | Time delay between operations (adjustable during sort) |
| **Elements** | 10-200 | Number of bars to sort (disabled during sort) |
| **Sort Button** | - | Start the sorting animation |
| **Reset Button** | - | Randomize the bars |

## Technical Details

### Performance Optimizations

- **Canvas Rendering** - Direct GPU drawing instead of SwiftUI views
  - 5-10x faster than traditional view-based approach
  - Single view instead of 100-200 individual views
  - Maintains 60fps even with 200 bars at 1ms speed

- **Memory Management**
  - Pre-allocated arrays with `reserveCapacity()`
  - Reuses memory with `keepingCapacity: true`
  - Equatable conformance reduces unnecessary updates

- **Async/Await Architecture**
  - Non-blocking UI updates
  - Cancellable sort operations
  - Real-time speed adjustments

### Architecture

```
SortAnimation/
├── Models.swift              # Data models (Bar, BarState, SortAlgorithm)
├── SortingViewModel.swift    # Business logic and sorting algorithms
├── CanvasBarChartView.swift  # High-performance Canvas rendering
├── ContentView.swift         # Main UI and controls
└── SortAnimationApp.swift    # App entry point
```

## How It Works

### Swap-Based Algorithms
(Bubble, Selection, Insertion, Quick, Heap, Shell, Cocktail Shaker)

- Use horizontal crossing animations
- Bars physically move to swap positions
- Offset-based animation with SwiftUI

### Rebuild-Based Algorithms
(Merge, Counting, Radix)

- Build new sorted arrays
- Instant reorganization with visual sweeps
- Highlights show placement order

## Building and Running

### Requirements
- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/SortAnimation.git
cd SortAnimation
```

2. Open in Xcode:
```bash
open SortAnimation.xcodeproj
```

3. Build and run (⌘R)

## Usage Tips

- Start with **100 elements** at **2ms speed** for a great overview
- Try **Quick Sort** or **Merge Sort** for fastest completion
- Use **Bubble Sort** or **Cocktail Shaker** to see classic swapping
- Watch **Radix Sort** organize by digits (ones, tens, hundreds)
- Increase to **200 elements** to stress-test performance
- Adjust speed in **real-time** to slow down interesting moments

## Algorithm Comparison

| Algorithm | Time Complexity | Space | Stable | In-Place |
|-----------|----------------|-------|--------|----------|
| Bubble Sort | O(n²) | O(1) | ✅ | ✅ |
| Selection Sort | O(n²) | O(1) | ❌ | ✅ |
| Insertion Sort | O(n²) | O(1) | ✅ | ✅ |
| Quick Sort | O(n log n) avg | O(log n) | ❌ | ✅ |
| Merge Sort | O(n log n) | O(n) | ✅ | ❌ |
| Heap Sort | O(n log n) | O(1) | ❌ | ✅ |
| Shell Sort | O(n log n)* | O(1) | ❌ | ✅ |
| Cocktail Shaker | O(n²) | O(1) | ✅ | ✅ |
| Counting Sort | O(n + k) | O(k) | ✅ | ❌ |
| Radix Sort | O(d × n) | O(n + k) | ✅ | ❌ |

*Shell Sort complexity depends on gap sequence

## Color Legend

- 🔵 **Blue** - Unsorted elements
- 🔴 **Red** - Elements being compared or moved
- 🟢 **Green** - Sorted elements in final position

## Future Enhancements

- [ ] Add more algorithms (Tim Sort, Bitonic Sort)
- [ ] Step-by-step mode
- [ ] Algorithm complexity visualization
- [ ] Sound effects
- [ ] Export animation as video
- [ ] Comparison mode (run multiple algorithms side-by-side)
- [ ] Custom color themes

## License

MIT License - see LICENSE file for details

## Credits

Created by Alec Saunders

Built with SwiftUI and the Canvas API for maximum performance.
