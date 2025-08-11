//
//  StaticView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//

import SwiftUI


struct StaticViewOld: View {
    @State private var sliderValue = 50.0
    @State private var brightness: CGFloat = 0.5
    @State private var speed: CGFloat = 0.5
    @State private var BrightnessIcon = "sun.min.fill"
    @State private var SpeedIcon = "tortoise.fill"
    @State private var showPicker = false
    @State private var CurrColor: UIColor = UIColor(red: 1, green: 1, blue:1, alpha: 1)
    @ObservedObject var blemanager: BLEManager
    @ObservedObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    
    init(appState: AppState, ble: BLEManager){
        self.appState = appState
        self.blemanager = ble
    }
    
    
    var body: some View {
            VStack(spacing: 20){
                Image(systemName: "lightbulb")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 300)

                
                    VStack{
                        
                        Button("Pick a color"){
                            showPicker = true
                        }
                        
                        HStack{
                            VStack {
                                CustomSlider(
                                    sliderProgress: $brightness,
                                    symbol: .init(
                                        icon: BrightnessIcon,
                                        tint: .gray,
                                        font: .system(size: 25),
                                        padding: 20,
                                        display: true,
                                        alignment: .bottom
                                    ),
                                    axis: .vertical,
                                    tint: .white
                                )
                                .frame(width: 60, height: 180)
                                .padding()
                                Text("Brightness")
                                    .font(.system(size: 15, weight: .bold, design: .default))
                            }.padding()
                        }
                    }.onChange(of: CurrColor) { oldValue, newValue in
                        //blemanager.sendCommand("color:R\(Int((100*newValue).rounded()))")
                    }
                    
                    .onChange(of: speed) { oldValue, newValue in
                        blemanager.sendCommand("speed:\(Int((100*newValue).rounded())+1)")
                        if newValue > 0.5 {
                            withAnimation {
                                SpeedIcon = "hare.fill"
                            }
                        }else {
                            withAnimation {
                                SpeedIcon = "tortoise.fill"
                            }
                        }
                    }
                    .onChange(of: brightness) { oldValue, newValue in
                        blemanager.sendCommand("brightness:\(Int((255*newValue).rounded())+1)")
                        if newValue > 0.5 {
                            withAnimation {
                                BrightnessIcon = "sun.max.fill"
                            }
                        }else {
                            withAnimation {
                                BrightnessIcon = "sun.min.fill"
                            }
                        }
                    }
                    
        }
        
    }
        
        
    
}


//#Preview {
//    StaticView()
//}
