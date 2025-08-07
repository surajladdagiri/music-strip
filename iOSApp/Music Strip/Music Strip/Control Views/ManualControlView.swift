//
//  ManualControlView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//

import SwiftUI

struct ManualControlView: View {
    @State var GoToStatic = false
    @State var GoToDynamic = false
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
                    .padding(.bottom, 200)
                    VStack{
                        HStack{
                            VStack{
                                Button {
                                    blemanager.sendCommand("manual:static_single")
                                    GoToStatic = true
                                } label:{
                                    Image(systemName: "pause.circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                
                                Text("Static")
                                    .fontWeight(.bold)
                            }.padding()
                            
                            VStack{
                                Button {
                                    blemanager.sendCommand("manual:fade")
                                    GoToDynamic = true
                                } label:{
                                    
                                    Image(systemName: "forward.circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                
                                Text("Fade")
                                    .fontWeight(.bold)
                            }.padding()
                        }
                        
                        
                        HStack{
                            VStack{
                                Button {
                                    blemanager.sendCommand("manual:snake")
                                    GoToDynamic = true
                                } label:{
                                    Image(systemName: "arrowshape.right.circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                
                                Text("Snake")
                                    .fontWeight(.bold)
                            }.padding()
                            
                            VStack{
                                Button {
                                    blemanager.sendCommand("manual:swap")
                                    GoToDynamic = true
                                } label:{
                                    
                                    Image(systemName: "forward.end.circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                }
                                .frame(width: 150, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(30)
                                
                                Text("Swap")
                                    .fontWeight(.bold)
                            }.padding()
                        }
                        
                    //}
                    .navigationDestination(isPresented: $GoToStatic){
                        StaticView(appState: appState, ble: blemanager)
                    }
                    .navigationDestination(isPresented:$GoToDynamic){
                        DynamicView(appState: appState, ble: blemanager)
                    }
                    .onChange(of: scenePhase){ oldPhase, newPhase in
                        if newPhase == .background || newPhase == .inactive {
                            blemanager.disconnect()
                        }
                    }
                    
                    
                
            }
        }
        
    }
}


//#Preview {
//    ManualControlView()
//}
