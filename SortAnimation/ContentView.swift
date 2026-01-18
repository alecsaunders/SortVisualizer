//
//  ContentView.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/17/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SortingViewModel()
    @State private var showingAlgorithmInfo = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Control bar for sliders (always visible)
            controlBar
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
                .background(.ultraThinMaterial)
            
            Divider()
            
            // Bar chart visualization
            CanvasBarChartView(
                bars: viewModel.bars,
                maxValue: viewModel.numberOfElements
            )
            .padding(20)
        }
        .frame(minWidth: 800, minHeight: 500)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Button {
                    showingAlgorithmInfo.toggle()
                } label: {
                    Label("Info", systemImage: "info.circle")
                }
                .labelStyle(.iconOnly)
                .help("Algorithm information")
                .popover(isPresented: $showingAlgorithmInfo, arrowEdge: .bottom) {
                    AlgorithmInfoView(algorithm: viewModel.selectedAlgorithm)
                }
                
                Picker("Algorithm", selection: $viewModel.selectedAlgorithm) {
                    ForEach(SortAlgorithm.allCases, id: \.self) { algorithm in
                        Text(algorithm.rawValue).tag(algorithm)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
                .disabled(viewModel.isSorting)
                .help("Choose sorting algorithm")
            }
            
            ToolbarItemGroup(placement: .automatic) {
                Group {
                    Button {
                        viewModel.nextStep()
                    } label: {
                        Label("Step", systemImage: "arrow.right")
                    }
                    .help("Next step (→)")
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(viewModel.isSorting && !viewModel.isPaused)
                    
                    if viewModel.isSorting {
                        Button {
                            viewModel.togglePause()
                        } label: {
                            Label(viewModel.isPaused ? "Resume" : "Pause", 
                                  systemImage: viewModel.isPaused ? "play.fill" : "pause.fill")
                        }
                        .help(viewModel.isPaused ? "Resume sorting (Space)" : "Pause sorting (Space)")
                        .keyboardShortcut(.space, modifiers: [])
                    } else {
                        Button {
                            viewModel.startSort()
                        } label: {
                            Label("Sort", systemImage: "play.fill")
                        }
                        .keyboardShortcut(.return, modifiers: [])
                        .help("Start sorting (⏎)")
                    }
                }
                
                Button {
                    viewModel.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .help("Reset (⌘R)")
                .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
    
    private var controlBar: some View {
        HStack(spacing: 24) {
            // Elements control
            HStack(spacing: 8) {
                Text("Elements:")
                    .foregroundStyle(.secondary)
                    .frame(width: 70, alignment: .trailing)
                Slider(
                    value: Binding(
                        get: { Double(viewModel.numberOfElements) },
                        set: { viewModel.numberOfElements = Int($0) }
                    ),
                    in: 10...200,
                    step: 10
                )
                .frame(width: 200)
                .disabled(viewModel.isSorting)
                .onChange(of: viewModel.numberOfElements) { oldValue, newValue in
                    if !viewModel.isSorting {
                        viewModel.reset()
                    }
                }
                Text("\(viewModel.numberOfElements)")
                    .monospacedDigit()
                    .frame(width: 40, alignment: .leading)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 20)
            
            // Speed control
            HStack(spacing: 8) {
                Text("Speed:")
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
                Slider(value: $viewModel.speed, in: 0...1000, step: 10)
                    .frame(width: 200)
                Text("\(Int(viewModel.speed)) ms")
                    .monospacedDigit()
                    .frame(width: 60, alignment: .leading)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
