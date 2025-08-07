//
//  ModeView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//

import SwiftUI





struct ModeView: View {
    @State var GoToManual = false
    @ObservedObject var blemanager: BLEManager
    @ObservedObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    
    init(appState: AppState, ble: BLEManager){
        self.appState = appState
        self.blemanager = ble
    }
    
    var body: some View {
            NavigationStack {
                VStack(spacing: 20){
                    Image(systemName: "lightbulb")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.yellow)
                        .padding(.bottom, 400)
                        HStack{
                            VStack{
                                Button {
                                    blemanager.sendCommand("mode:off")
                                } label:{
                                    Image(systemName: "poweroff")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                
                                Text("Off")
                                    .fontWeight(.bold)
                            }.padding()
                            
                            VStack{
                                Button {
                                    blemanager.sendCommand("mode:manual")
                                    GoToManual = true
                                } label:{
                                    
                                    Image(systemName: "command")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                
                                Text("Manual")
                                    .fontWeight(.bold)
                            }.padding()
                        }
                    //}
                    .navigationDestination(isPresented: $GoToManual){
                        ManualControlView(appState: appState, ble: blemanager)
                    }
                }
                .onChange(of: scenePhase){ oldPhase, newPhase in
                    if newPhase == .background || newPhase == .inactive {
                        blemanager.disconnect()
                    }
                }
            }
        
        
    }
}


//#Preview {
//    ModeView()
//}
