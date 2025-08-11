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
    
    init(spotifymanager: SpotifyManager){
        self.spotifymanager = spotifymanager
        if spotifymanager.duplicates{
            selectedMode = .duplicates
        }else {
            selectedMode = .no_duplicates
        }
        sliderValue = Double(spotifymanager.numColors)
        
    }
    
    var body: some View {
        VStack {

            Text("Mode:")
                .font(.system(size: 34, weight: .bold, design: .default))
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
                            in: 2...10,         // Define the minimum and maximum values
                            step: 1.0           // Set the step increment (e.g., 10.0 for increments of 10)
                        )
                        .padding() // Add some padding around the slider

                        // Display the current value of the slider
                        Text("Value: \(sliderValue, specifier: "%.0f")")
            
        }.onChange(of: selectedMode) { oldValue, newValue in
            print(newValue)
            if newValue == mode.duplicates{
                spotifymanager.duplicates = true
            }else{
                spotifymanager.duplicates = false
            }
        }
        .onChange(of: sliderValue){oldValue, newValue in
            spotifymanager.numColors = Int(newValue)
        }
    }
}

