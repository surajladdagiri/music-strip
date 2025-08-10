//
//  ContentView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//


import SwiftUI

/*
 @State private var savedColors: [Color] = [.red, .blue, .green, .yellow]  // A few colors to test the list

     var body: some View {
         VStack(spacing: 20) {
             Image(systemName: "lightbulb")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 80, height: 80)
                 .foregroundColor(.yellow)
                 .padding(.bottom, 20)

             Text("Saved Colors:")
                 .font(.system(size: 20, weight: .bold, design: .default))
                 .padding()

             // Display the list of colors
             List(savedColors, id: \.self) { color in
                 Text("Color")
                     .foregroundColor(color)  // Change text color to the color stored
                     .font(.system(size: 20, weight: .bold, design: .default))
                     .padding(10)
                     .background(color.opacity(0.3))  // Slight background color to highlight the color
                     .cornerRadius(10)
             }
             .padding(.horizontal)

             // Just for UI testing: a button to test adding a new color
             Button("Add Random Color") {
                 let randomColor = [Color.red, Color.blue, Color.green, Color.yellow, Color.purple].randomElement()!
                 savedColors.append(randomColor)  // Add a new color to the list
             }
             .padding()
             .background(Color.blue)
             .foregroundColor(.white)
             .cornerRadius(10)
         }
         .padding()
     }
 */



struct ContentView: View {
    @State private var sliderValue = 50.0
    @State private var brightness: CGFloat = 0.5
    @State private var speed: CGFloat = 0.5
    @State private var BrightnessIcon = "sun.min.fill"
    @State private var SpeedIcon = "tortoise.fill"
    @State private var showPicker = false
    @State private var CurrColor: UIColor = UIColor(red: 0.5, green: 1, blue:1, alpha: 1)
    @State private var savedColors: [Color] = [.red, .blue, .green, .yellow, .indigo, .red, .orange, .yellow, .green, .blue, .indigo, .purple]
    //@ObservedObject var blemanager: BLEManager
    //@ObservedObject var appState: AppState
    //@Environment(\.scenePhase) private var scenePhase
    
    //init(appState: AppState, ble: BLEManager){
    //    self.appState = appState
    //    self.blemanager = ble
    //}
    
    
    var body: some View {
            VStack(spacing: 20){
                Image(systemName: "lightbulb")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                
                    VStack{
                        
                        Button("Pick a color"){
                            showPicker = true
                        }.foregroundColor(Color(uiColor: CurrColor))
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .padding(10)
                            .background(Color(uiColor: CurrColor).opacity(0.3))
                            .cornerRadius(10)
                            .padding(.top)
                        Text("Saved Colors:")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .padding(.top, 5)

                            List(savedColors, id: \.self) { color in
                                    Button("Color"){
                                        
                                    }
                                        .foregroundColor(color)  // Change text color to the color stored
                                        .font(.system(size: 20, weight: .bold, design: .default))
                                        .padding(10)
                                        .background(color.opacity(0.3))  // Slight background color to highlight the color
                                        .cornerRadius(10)
                                
                                
                            }
                            .padding(.bottom)
                            .contentMargins(.top, 0)
                        Button("Save Current Color") {
                            
                        }.font(.system(size: 20, weight: .bold, design: .default))
                        .padding(15)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(10)
                        //.padding(.bottom)
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
                        //blemanager.sendCommand("speed:\(Int((100*newValue).rounded())+1)")
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
                        //blemanager.sendCommand("brightness:\(Int((255*newValue).rounded())+1)")
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
                    //.onChange(of: scenePhase){ oldPhase, newPhase in
                    //    if newPhase == .background || newPhase == .inactive {
                    //        blemanager.disconnect()
                    //    }
                    //}
        }
        
    }
}


#Preview {
    ContentView()
}
