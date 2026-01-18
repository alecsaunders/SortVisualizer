//
//  ContentView.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SortingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Controls at the top
            controlsView
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
            
            // Bar chart visualization
            CanvasBarChartView(
                bars: viewModel.bars,
                maxValue: viewModel.numberOfElements
            )
            .padding(20)
        }
        .frame(minWidth: 800, minHeight: 500)
    }
    
    private var controlsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                // Algorithm Picker
                HStack {
                    Text("Algorithm:")
                        .frame(width: 80, alignment: .trailing)
                    Picker("", selection: $viewModel.selectedAlgorithm) {
                        ForEach(SortAlgorithm.allCases, id: \.self) { algorithm in
                            Text(algorithm.rawValue).tag(algorithm)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                    .disabled(viewModel.isSorting)
                }
                
                // Speed Slider
                HStack {
                    Text("Speed:")
                        .frame(width: 60, alignment: .trailing)
                    Slider(value: $viewModel.speed, in: 1...1000, step: 1)
                        .frame(width: 200)
                    Text("\(Int(viewModel.speed)) ms")
                        .frame(width: 60, alignment: .leading)
                        .monospacedDigit()
                }
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                // Number of Elements
                HStack {
                    Text("Elements:")
                        .frame(width: 80, alignment: .trailing)
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.numberOfElements) },
                            set: { viewModel.numberOfElements = Int($0) }
                        ),
                        in: 10...200,
                        step: 1
                    )
                    .frame(width: 200)
                    .disabled(viewModel.isSorting)
                    .onChange(of: viewModel.numberOfElements) { oldValue, newValue in
                        if !viewModel.isSorting {
                            viewModel.reset()
                        }
                    }
                    Text("\(viewModel.numberOfElements)")
                        .frame(width: 60, alignment: .leading)
                        .monospacedDigit()
                }
                
                // Buttons
                HStack(spacing: 10) {
                    Button("Sort") {
                        viewModel.startSort()
                    }
                    .disabled(viewModel.isSorting)
                    .buttonStyle(.borderedProminent)
                    
                    Button("Reset") {
                        viewModel.reset()
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
