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
- 🎨 **Customizable Colors** - Choose from Classic, Educational, or Custom color schemes
- 🔊 **Sound Effects** - Audibilization following Sound of Sorting methodology
- 🌊 **Final Sweep** - Visual and audio confirmation wave when sorting completes
- 👁️ **Step-by-Step Mode** - Pause, play, and step through algorithms
- 🎨 **Inspector Sidebar** - All controls in one convenient panel
- 📊 **Scalable** - From 10 to 200 elements
- 📈 **Live Statistics** - Real-time tracking of comparisons, swaps, and performance

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

### Toolbar
| Control | Description |
|---------|-------------|
| **Info Button** | Show algorithm information (Big-O notation and description) |
| **Algorithm Picker** | Select from 10 sorting algorithms |
| **Sound Toggle** | Enable/disable sound effects |
| **Step Button** | Execute next sorting step (→) |
| **Play/Pause** | Start sorting or pause/resume (Space) |
| **Reset Button** | Randomize the bars (⌘R) |
| **Inspector Toggle** | Show/hide inspector sidebar |

### Inspector Sidebar
All configuration controls are accessed via the Inspector sidebar (toggle with toolbar button):

#### Configuration
- **Elements** (10-200, step 10) - Number of bars to sort
- **Speed** (0-1000 ms, step 10) - Delay between operations

#### Color Scheme
- **Classic** - White/Red/White (Sound of Sorting style)
- **Educational** - Blue/Red/Green (distinct sorted state)
- **Custom** - Choose your own colors for each state
- **Live Preview** - See color changes in real-time

#### Sound
- **Enable/Disable** - Toggle sound effects on/off
- **Volume** - Adjust sound volume (0-100%)
- **Sustain** - Control envelope duration

#### Statistics
- **Comparisons** - Number of element comparisons made
- **Swaps** - Number of element swaps performed
- **Array Access** - Total array read/write operations
- **Time** - Elapsed time in seconds

## Technical Details

### Performance Optimizations

- **Canvas Rendering** - Direct GPU drawing instead of SwiftUI views
  - 5-10x faster than traditional view-based approach
  - Single view instead of 100-200 individual views
  - Maintains 60fps even with 200 bars at 1ms speed

- **Throttled Updates** - Smart publishing reduces UI overhead
  - Working copy for mutations, throttled publishes at 60fps
  - Prevents excessive SwiftUI diffing and re-renders
  - Version-based invalidation for final sweep animations

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
├── ColorScheme.swift         # Color scheme definitions and persistence
├── SortingViewModel.swift    # Business logic and sorting algorithms
├── SoundGenerator.swift      # Audio synthesis and sound effects
├── CanvasBarChartView.swift  # High-performance Canvas rendering
├── InspectorView.swift       # Inspector sidebar UI
├── AlgorithmInfoView.swift   # Algorithm information popover
├── ContentView.swift         # Main UI and toolbar
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
- macOS 13.0 or later (for Inspector API support)
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

- **Open the Inspector** - Click the sidebar button in the toolbar to access all controls
- Start with **100 elements** at **10ms speed** for a great overview
- Try **Quick Sort** or **Merge Sort** for fastest completion
- Use **Bubble Sort** or **Cocktail Shaker** to see classic swapping
- Watch **Radix Sort** organize by digits (ones, tens, hundreds)
- **Step through algorithms** - Use the Step button or → key to advance one operation at a time
- **Enable sound** - Toggle sound effects to hear the audibilization of comparisons
- **Final sweep** - After sorting completes, watch the satisfying visual and audio confirmation wave
- **Customize colors** - Switch to Classic mode for white/red, or create your own scheme
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

## Color Schemes

### Classic (Sound of Sorting)
- ⚪ **White** - Unsorted elements
- 🔴 **Red** - Elements being compared or moved
- ⚪ **White** - Sorted elements (returns to unsorted color)

### Educational (Default)
- 🔵 **Blue** - Unsorted elements
- 🔴 **Red** - Elements being compared or moved
- 🟢 **Green** - Sorted elements in final position

### Custom
- Choose any color for each state using the color pickers in the Inspector

## Testing

The project includes comprehensive test coverage:

- **Unit Tests** (`SortingAlgorithmsUnitTests`) - 80+ pure tests for sorting algorithm correctness
- **Integration Tests** (`SortingViewModelIntegrationTests`) - 30+ tests for ViewModel behavior
- **UI Tests** (`SortAnimationUITests`) - End-to-end app testing

Run tests in Xcode with **⌘U** or via command line:

```bash
xcodebuild test -scheme SortAnimation -destination 'platform=macOS'
```

## Future Enhancements

- [ ] Add more algorithms (Tim Sort, Bitonic Sort)
- [ ] Export animation as video
- [ ] Comparison mode (run multiple algorithms side-by-side)

## License

MIT License - see LICENSE file for details

## Acknowledgments

This project is inspired by [The Sound of Sorting](https://panthema.net/2013/sound-of-sorting/) by Timo Bingmann (2013), which pioneered the visualization and audibilization of sorting algorithms. The original Sound of Sorting is licensed under GPL v3 and available at [GitHub](https://github.com/bingmann/sound-of-sorting).

**Sort Visualizer** is an independent implementation written from scratch in Swift/SwiftUI, incorporating similar concepts:
- Visual representation of sorting algorithms with colored bars
- Audibilization using tone frequencies mapped to element values
- Final sweep animation confirming sort completion
- Multiple sorting algorithm demonstrations

Special thanks to Timo Bingmann for creating the original Sound of Sorting project that inspired sorting algorithm visualizers worldwide.

## Credits

Created by Alec Saunders

Built with SwiftUI and the Canvas API for maximum performance.
