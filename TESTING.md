# Testing Architecture

## Overview

The test suite is now organized into three layers:

### 1. Pure Unit Tests (`SortingAlgorithmsUnitTests.swift`)
- **Purpose**: Test sorting algorithm logic in isolation
- **Characteristics**:
  - No UI dependencies
  - No async/await delays
  - Instant execution
  - Tests pure functions in `SortingAlgorithms.swift`
- **Coverage**: 80+ tests covering all 10 algorithms with various inputs
- **Benefits**:
  - Fast (completes in milliseconds)
  - Deterministic (no timing issues)
  - Easy to debug
  - Can test edge cases easily

### 2. Integration Tests (`SortingViewModelIntegrationTests.swift`)
- **Purpose**: Test ViewModel behavior including visualization
- **Characteristics**:
  - Tests `SortingViewModel` with async sorting
  - Includes delays for animation/visualization
  - Tests state management, statistics, pause/resume
  - Does NOT launch the actual app
- **Coverage**: 30+ tests covering ViewModel functionality
- **Benefits**:
  - Tests the full sorting pipeline with visualization
  - Validates UI state updates
  - Tests real-world usage patterns

### 3. UI Tests (`SortAnimationUITests.swift`)
- **Purpose**: Test the actual macOS app UI
- **Characteristics**:
  - Launches the full app
  - Uses XCUIApplication
  - Tests UI interaction
- **Coverage**: Launch tests
- **Benefits**:
  - End-to-end validation
  - Tests actual user experience

## Architecture Separation

### Pure Logic Layer (`SortingAlgorithms.swift`)
```
SortingAlgorithms
├── Static functions for each algorithm
├── Generic over Comparable types
├── Pure functional (no side effects)
└── No UI dependencies
```

### Visualization Layer (`SortingViewModel.swift`)
```
SortingViewModel
├── Uses SortingAlgorithms for reference
├── Implements visualization logic
├── Manages bar state, colors, animations
├── Tracks statistics
└── Handles audio feedback
```

## Why This Structure?

1. **Separation of Concerns**: Logic is separate from visualization
2. **Testability**: Can test algorithms instantly without UI
3. **Maintainability**: Changes to one layer don't break the other
4. **Performance**: Pure tests run in milliseconds
5. **Debugging**: Easy to isolate algorithmic vs visualization bugs

## Test Execution Times

- **Pure Unit Tests**: ~0.1 seconds (all 80+ tests)
- **Integration Tests**: ~30-60 seconds (includes async delays)
- **UI Tests**: ~10 seconds (app launch + interaction)

## Running Tests

```bash
# Run all tests
xcodebuild test -scheme SortAnimation

# Run only pure unit tests (fast)
xcodebuild test -scheme SortAnimation -only-testing:SortAnimationTests/SortingAlgorithmsUnitTests

# Run only integration tests
xcodebuild test -scheme SortAnimation -only-testing:SortAnimationTests/SortingViewModelIntegrationTests

# Run only UI tests
xcodebuild test -scheme SortAnimation -only-testing:SortAnimationUITests
```

## Adding New Tests

### For Algorithm Logic
Add to `SortingAlgorithmsUnitTests.swift`:
```swift
@Test func myNewAlgorithmAscending() {
    let input = [3, 1, 2]
    let result = SortingAlgorithms.myNewAlgorithm(input, order: .ascending)
    #expect(result == [1, 2, 3])
}
```

### For ViewModel Behavior
Add to `SortingViewModelIntegrationTests.swift`:
```swift
@Test func myNewFeature() async {
    let viewModel = SortingViewModel()
    // Test ViewModel behavior
}
```

### For UI Interaction
Add to `SortAnimationUITests.swift`:
```swift
func testMyNewUIFeature() throws {
    let app = XCUIApplication()
    app.launch()
    // Test UI elements
}
```
