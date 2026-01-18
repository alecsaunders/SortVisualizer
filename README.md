# Application

This is a macOS Swift app to visually show different sort algorithms.

# Algorithms

The app should be able to animate multiple sort algorithms. We will start with just a few:

- Bubble
- Selection

# Animation

Show moving the bars with an animation so you can actually see the bar move from it's current position to it's next position or show two bars moving if they are switching possitions.

For instance, in a buble sort show the two items (another color) to compare, then if they need to switch places, show an animation of both of the bars moving into thier new spots.

# Controls
- Algorithm: Which algorithm to use
- Speed: how much time in ms to wait before each comparison
- Number of elements: Number of bars to show at the same time
- Reset: randomize the elements again

# UI Components

- The current app uses GeometryReader and Rectangles
- If there is a more performant way to organize large amounts of bars and animate them, go with the most performant option.