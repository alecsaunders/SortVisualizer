//
//  InspectorView.swift
//  SortAnimation
//
//  Created by Saunders, Alec on 1/18/26.
//

import SwiftUI

struct InspectorView: View {
    @ObservedObject var viewModel: SortingViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Color Scheme Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color Scheme")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(ColorSchemeType.allCases) { schemeType in
                            HStack(alignment: .top, spacing: 8) {
                                RadioButton(
                                    isSelected: viewModel.colorSchemeType == schemeType,
                                    label: schemeType.rawValue
                                ) {
                                    viewModel.colorSchemeType = schemeType
                                }
                                
                                Spacer()
                            }
                            
                            if schemeType != .custom {
                                Text(schemeType.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 24)
                            }
                        }
                    }
                    
                    // Custom color pickers (only shown when Custom is selected)
                    if viewModel.colorSchemeType == .custom {
                        Divider()
                            .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ColorPickerRow(
                                title: "Unsorted",
                                color: Binding(
                                    get: { viewModel.customColors.unsorted.color },
                                    set: { viewModel.customColors.unsorted = CodableColor($0) }
                                )
                            )
                            
                            ColorPickerRow(
                                title: "Comparing",
                                color: Binding(
                                    get: { viewModel.customColors.comparing.color },
                                    set: { viewModel.customColors.comparing = CodableColor($0) }
                                )
                            )
                            
                            ColorPickerRow(
                                title: "Sorted",
                                color: Binding(
                                    get: { viewModel.customColors.sorted.color },
                                    set: { viewModel.customColors.sorted = CodableColor($0) }
                                )
                            )
                        }
                    }
                    
                    // Preview
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 4) {
                            PreviewBar(color: viewModel.currentColors.unsorted.color, label: "Unsorted")
                            PreviewBar(color: viewModel.currentColors.comparing.color, label: "Comparing")
                            PreviewBar(color: viewModel.currentColors.sorted.color, label: "Sorted")
                        }
                        .frame(height: 80)
                    }
                }
                
                Divider()
                
                // Sound Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sound")
                        .font(.headline)
                    
                    Toggle("Enable Sound", isOn: Binding(
                        get: { viewModel.soundGenerator.isEnabled },
                        set: { viewModel.soundGenerator.isEnabled = $0 }
                    ))
                    
                    if viewModel.soundGenerator.isEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Volume")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $viewModel.soundVolume, in: 0...1)
                            
                            Text("Sustain")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                            Slider(value: $viewModel.soundSustain, in: 0...1)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 220, idealWidth: 250, maxWidth: 300)
    }
}

// MARK: - Helper Views

struct RadioButton: View {
    let isSelected: Bool
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                Text(label)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 80, alignment: .leading)
            ColorPicker("", selection: $color)
                .labelsHidden()
        }
    }
}

struct PreviewBar: View {
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    InspectorView(viewModel: SortingViewModel())
        .frame(height: 600)
}
