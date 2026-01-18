//
//  CanvasBarChartView.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import SwiftUI

struct CanvasBarChartView: View {
    let bars: [Bar]
    let maxValue: Int
    
    var body: some View {
        Canvas { context, size in
            let barCount = bars.count
            guard barCount > 0 else { return }
            
            // Calculate dimensions
            let spacing: CGFloat = max(1, min(4, size.width / CGFloat(barCount) / 10))
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = (size.width - totalSpacing) / CGFloat(barCount)
            let maxHeight = size.height
            
            // Draw each bar
            for (index, bar) in bars.enumerated() {
                let barHeight = CGFloat(bar.value) * maxHeight / CGFloat(maxValue)
                
                // Calculate position with offset for animation
                let baseX = CGFloat(index) * (barWidth + spacing)
                let offsetX = bar.offset * (barWidth + spacing)
                let x = baseX + offsetX
                let y = size.height - barHeight
                
                // Create rectangle
                let rect = CGRect(
                    x: x,
                    y: y,
                    width: barWidth,
                    height: barHeight
                )
                
                // Get color based on state
                let color: Color = bar.state.color
                
                // Draw the bar
                context.fill(
                    Path(rect),
                    with: .color(color)
                )
            }
        }
    }
}

#Preview {
    CanvasBarChartView(
        bars: [
            Bar(value: 5, state: .unsorted),
            Bar(value: 10, state: .comparing),
            Bar(value: 8, state: .sorted),
            Bar(value: 15, state: .unsorted)
        ],
        maxValue: 20
    )
    .frame(height: 300)
    .padding()
}
