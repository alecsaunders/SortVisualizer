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
    @State private var showInspector = false
    
    var body: some View {
        // Bar chart visualization
        CanvasBarChartView(
            bars: viewModel.bars,
            maxValue: viewModel.numberOfElements,
            colors: viewModel.currentColors
        )
        .padding(20)
        .frame(minWidth: 800, minHeight: 500)
        .inspector(isPresented: $showInspector) {
            InspectorView(viewModel: viewModel)
        }
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
            
            ToolbarItem(placement: .status) {
                Button {
                    viewModel.soundGenerator.isEnabled.toggle()
                } label: {
                    Label("Sound", systemImage: viewModel.soundGenerator.isEnabled ? "speaker.wave.2" : "speaker.slash")
                }
                .help(viewModel.soundGenerator.isEnabled ? "Sound enabled (click to disable)" : "Sound disabled (click to enable)")
            }
            
            ToolbarItemGroup(placement: .automatic) {
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
                
                Button {
                    viewModel.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .help("Reset (⌘R)")
                .keyboardShortcut("r", modifiers: .command)
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    showInspector.toggle()
                } label: {
                    Label("Inspector", systemImage: "sidebar.right")
                }
                .help("Show Inspector")
            }
        }
    }
}

#Preview {
    ContentView()
}
