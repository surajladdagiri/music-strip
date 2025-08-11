//
//  StaticView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//

import SwiftUI


struct StaticView: View {
    @State private var sliderValue = 50.0
    @State private var brightness: CGFloat = 0.5
    @State private var speed: CGFloat = 0.5
    @State private var BrightnessIcon = "sun.min.fill"
    @State private var SpeedIcon = "tortoise.fill"
    @State private var showPicker = false
    @State private var rValue = 255.0
    @State private var gValue = 255.0
    @State private var bValue = 0.0
    @State private var CurrColor: UIColor = UIColor(red: 1, green: 1, blue:0, alpha: 1)
    @State private var CurrColorRGB = (255,255,0)
    @ObservedObject var blemanager: BLEManager
    @ObservedObject var appState: AppState
    @State private var showingAlert = false
    @State private var show_rename = false
    @State private var inputText = ""
    @State private var rename_color_text = ""
    @State private var rename_color = (255,255,255)
    @State private var renameText = ""
    @Environment(\.scenePhase) private var scenePhase
    @State private var saved_colors: [String:(Int, Int, Int)] = ["White":(255,255,255), "Black":(0,0,0)]
    
    func saveColorDict(_ dict: [String: (Int, Int, Int)]) {
        var storageDict = [String: [Int]]()
        
        for (key, tuple) in dict {
            storageDict[key] = [tuple.0, tuple.1, tuple.2]
        }
        
        UserDefaults.standard.set(storageDict, forKey: "saved_colors")
    }

    func loadColorDict() -> [String: (Int, Int, Int)]? {
        guard let storageDict = UserDefaults.standard.dictionary(forKey: "saved_colors") as? [String: [Int]] else {
            return nil
        }
        
        var colorDict = [String: (Int, Int, Int)]()
        
        for (key, array) in storageDict {
            if array.count == 3 {
                colorDict[key] = (array[0], array[1], array[2])
            }
        }
        
        return colorDict
    }
    
    
    init(appState: AppState, ble: BLEManager){
        guard let storageDict = UserDefaults.standard.dictionary(forKey: "saved_colors") as? [String: [Int]] else {
            self.appState = appState
            self.blemanager = ble
            return
        }
        
        var colorDict = [String: (Int, Int, Int)]()
        
        for (key, array) in storageDict {
            if array.count == 3 {
                colorDict[key] = (array[0], array[1], array[2])
            }
        }
        self.saved_colors = colorDict
        self.appState = appState
        self.blemanager = ble
    }
    
    var body: some View {
            VStack(spacing: 20){
                Image(systemName: "lightbulb")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(CurrColor))
                    VStack{
                        Slider(value: $rValue, in: 0...255, onEditingChanged: {editing in
                            //CurrColor = UIColor(red: (rValue/255.0), green: (gValue/255.0), blue: (bValue/255.0), alpha: 1)
                            if !editing {
                                blemanager.sendCommand("color:R\(Int(rValue))G\(Int(gValue))B\(Int(bValue))")
                            }
                        })
                        Slider(value: $gValue, in: 0...255, onEditingChanged: {editing in
                            //CurrColor = UIColor(red: (rValue/255.0), green: (gValue/255.0), blue: (bValue/255.0), alpha: 1)
                            if !editing {
                                blemanager.sendCommand("color:R\(Int(rValue))G\(Int(gValue))B\(Int(bValue))")
                            }
                        })
                        Slider(value: $bValue, in: 0...255, onEditingChanged: {editing in
                            //CurrColor = UIColor(red: (rValue/255.0), green: (gValue/255.0), blue: (bValue/255.0), alpha: 1)
                            if !editing {
                                blemanager.sendCommand("color:R\(Int(rValue))G\(Int(gValue))B\(Int(bValue))")
                            }
                        })
                                    Text("Current Value: \(Int(rValue)), \(Int(gValue)), \(Int(bValue))")
                        /*
                        Button("Send color"){
                            print("color:R\(Int(rValue))G\(Int(gValue))B\(Int(bValue))")
                            blemanager.sendCommand("color:R\(Int(rValue))G\(Int(gValue))B\(Int(bValue))")
                            //showPicker = true
                        }.buttonStyle(.borderedProminent)
                            .padding()
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .sheet(isPresented: $showPicker, content: {
                                        ColorPickerView(
                                            title: "Pick a Color",
                                            selectedColor: CurrColor,
                                            didSelectColor: { color in
                                                self.CurrColor = color
                                            }
                                        )
                                        .padding(.top, 8)
                                        .background(.white)
                                        .interactiveDismissDisabled(false)
                                        .presentationDetents([.height(640)])
                                        .overlay(alignment: .topTrailing, content: {
                                            Button(action: {
                                                print("color:R\(CurrColor.r)G\(CurrColor.r)B\(CurrColor.b)")
                                                blemanager.sendCommand("color:R\(CurrColor.r)G\(CurrColor.r)B\(CurrColor.b)")
                                                showPicker = false
                                            }, label: {
                                                Image(systemName: "xmark")

                                            })
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.gray.opacity(0.8))
                                            .padding(.all, 8)
                                            .background(Circle().fill(.gray.opacity(0.2)))
                                            .padding()
                                        })
                                    })
                        */
                        
                        Text("Saved Colors:")
                            .font(.system(size: 20, weight: .bold, design: .default))
                        
                        List {
                            ForEach(saved_colors.keys.sorted(), id: \.self) { key in
                                if let uiColor = saved_colors[key] {

                                    Button(action: {
                                        print("Tapped \(key)")
                                        CurrColor = UIColor(red: (CGFloat(uiColor.0))/255.0, green: (CGFloat(uiColor.1))/255.0, blue: (CGFloat(uiColor.2))/255.0, alpha: 1.0)
                                        CurrColorRGB = (uiColor.0, uiColor.1, uiColor.2)
                                        print("color:R\(uiColor.0)G\(uiColor.1)B\(uiColor.2)")
                                        blemanager.sendCommand("color:R\(uiColor.0)G\(uiColor.1)B\(uiColor.2)")
                                    }) {
                                        Text(key)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(uiColor: UIColor(red: (CGFloat(uiColor.0))/255.0, green: (CGFloat(uiColor.1))/255.0, blue: (CGFloat(uiColor.2))/255.0, alpha: 1.0)))
                                            .cornerRadius(8)
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button(role: .destructive) {
                                            saved_colors[key] = nil
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                                    .swipeActions(edge: .trailing){
                                        Button {
                                            show_rename = true
                                            rename_color = uiColor
                                            rename_color_text = key
                                            renameText = key
                                        } label: {
                                            Label("Rename", systemImage: "pencil")
                                        }
                                    }
 
                                }
                            }
                        }.contentMargins(.top, 0)
                        
                        Button("Save Current Color"){
                            showingAlert = true
                            
                        }.buttonStyle(.borderedProminent)
                            .padding()
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .alert("Enter Color Name", isPresented: $show_rename) {
                                TextField("Color Name", text: $renameText)
                                Button("Rename") {
                                    saved_colors[renameText] = rename_color
                                    saved_colors[rename_color_text] = nil
                                    saveColorDict(saved_colors)
                                }
                                Button("Cancel", role: .cancel) {
                                }
                            } message: {
                                Text("Please Input a Color Name")
                            }
                            .alert("Enter Color Name", isPresented: $showingAlert) {
                                    TextField("Color Name", text: $inputText)
                                    Button("Add") {
                                        saved_colors[inputText] = CurrColorRGB
                                        saveColorDict(saved_colors)
                                        inputText = ""
                                        
                                    }
                                    Button("Cancel", role: .cancel) {
                                    }
                                } message: {
                                    Text("Please Input a Color Name")
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
                        //blemanager.sendCommand("color:R\(newValue.r)G\(newValue.r)B\(newValue.b)")
                    }
                    .onChange(of: brightness) { oldValue, newValue in
                        blemanager.sendCommand("brightness:\(min(255, Int((255*newValue).rounded())+1))")
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
                    .onChange(of: rValue){oldValue, newValue in
                        CurrColor = UIColor(red: (rValue/255.0), green: (gValue/255.0), blue: (bValue/255.0), alpha: 1)
                        CurrColorRGB = (Int(rValue), Int(gValue), Int(bValue))
                    }
                    .onChange(of: gValue){oldValue, newValue in
                        CurrColor = UIColor(red: (rValue/255.0), green: (gValue/255.0), blue: (bValue/255.0), alpha: 1)
                        CurrColorRGB = (Int(rValue), Int(gValue), Int(bValue))
                    }
                    .onChange(of: bValue){oldValue, newValue in
                        CurrColor = UIColor(red: (rValue/255.0), green: (gValue/255.0), blue: (bValue/255.0), alpha: 1)
                        CurrColorRGB = (Int(rValue), Int(gValue), Int(bValue))
                    }
                    
        }
        
    }
        
        
    
}


//#Preview {
//    StaticView()
//}
