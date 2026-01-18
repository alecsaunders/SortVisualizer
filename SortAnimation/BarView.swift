//
//  BarView.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import SwiftUI

struct BarView: View {
    let bar: Bar
    let maxValue: Int
    let barWidth: CGFloat
    let maxHeight: CGFloat
    
    private var barHeight: CGFloat {
        CGFloat(bar.value) * maxHeight / CGFloat(maxValue)
    }
    
    var body: some View {
        Rectangle()
            .fill(bar.state.color)
            .frame(width: barWidth, height: barHeight)
    }
}

#Preview {
    BarView(bar: Bar(value: 10), maxValue: 20, barWidth: 20, maxHeight: 200)
}
