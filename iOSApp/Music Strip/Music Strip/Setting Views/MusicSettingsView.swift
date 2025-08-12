//
//  MusicSettingsView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/11/25.
//

import SwiftUI

enum mode{
    case duplicates, no_duplicates
}

struct MusicSettingsView: View {
    @State var selectedMode: mode
    @ObservedObject var spotifymanager: SpotifyManager
    @State var sliderValue: Double
    @State var selectedAlgorithm: Algorithm
    
    init(spotifymanager: SpotifyManager){
        self.spotifymanager = spotifymanager
        if spotifymanager.duplicates{
            selectedMode = .duplicates
        }else {
            selectedMode = .no_duplicates
        }
        
        self.selectedAlgorithm = spotifymanager.algorithm
        sliderValue = Double(spotifymanager.numColors)
        
    }
    
    var body: some View {
        VStack {

            Text("Mode:")
                .font(.system(size: 34, weight: .bold, design: .default))
                .padding()
            Picker("Select Algorithm:", selection: $selectedAlgorithm) {
                Text("Modified Median Cut Quantization (MMCQ)")
                    .tag(Algorithm.mmcq)
                Text("K-Means Clustering")
                    .tag(Algorithm.kmeans)
            }
            .padding()

            Picker("Select Mode:", selection: $selectedMode) {
                Text("Duplicates Allowed")
                    .tag(mode.duplicates)
                Text("No Duplicates Allowed")
                    .tag(mode.no_duplicates)
            }
            .padding()
                        Slider(
                            value: $sliderValue,
                            in: 2...10,         
                            step: 1.0
                        )
                        .padding()

                        Text("Value: \(sliderValue, specifier: "%.0f")")
            
        }.onChange(of: selectedMode) { oldValue, newValue in
            print(newValue)
            if newValue == mode.duplicates{
                spotifymanager.duplicates = true
            }else{
                spotifymanager.duplicates = false
            }
        }
        .onChange(of: selectedAlgorithm) { oldValue, newValue in
            print(newValue)
            spotifymanager.algorithm = newValue
        }

        .onChange(of: sliderValue){oldValue, newValue in
            spotifymanager.numColors = Int(newValue)
        }
    }
}

