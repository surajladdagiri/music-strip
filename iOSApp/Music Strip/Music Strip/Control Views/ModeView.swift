//
//  ModeView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//

import SwiftUI





struct ModeView: View {
    @State var GoToManual = false
    @State var GoToMusic = false
    @ObservedObject var blemanager: BLEManager
    @ObservedObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var spotifymanager: SpotifyManager
    private var spotify_connected = false
    init(appState: AppState, ble: BLEManager, spotifymanager: SpotifyManager){
        self.appState = appState
        self.blemanager = ble
        self.spotifymanager = spotifymanager
    }
    
    var body: some View {
            NavigationStack {
                VStack(spacing: 20){
                    Image(systemName: "lightbulb")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.yellow)
                        .padding(.bottom)
                    if let albumArt = spotifymanager.currAlbumArt {
                        if spotifymanager.appRemote.isConnected {
                            Image(uiImage: albumArt)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .cornerRadius(30)
                            Text(spotifymanager.currTitle)
                                .font(.system(size: 15, weight: .bold, design: .default))
                        }else {
                            Text("Reconnect to Spotify...")
                                .padding()
                        }
                                    
                                } else {
                                    Text("No album art available...")
                                        .padding()
                                }
                    VStack{
                        VStack{
                            Button {
                                if spotifymanager.appRemote.isConnected {
                                    blemanager.sendCommand("mode:spotify")
                                    GoToMusic = true
                                }else{
                                    spotifymanager.authorize()
                                }
                            } label:{
                                Image(systemName: "music.note")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                            }
                            .frame(width: 150, height: 150)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(30)
                            .onOpenURL { url in
                                spotifymanager.handleOpenURL(url)
                            }
                            
                            Text("Music")
                                .fontWeight(.bold)
                        }
                        
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
                        
                    }
                    
                    
                    
                    
                    .navigationDestination(isPresented: $GoToManual){
                        ManualControlView(appState: appState, ble: blemanager)
                    }
                    .navigationDestination(isPresented: $GoToMusic){
                        MusicView(appState: appState, ble: blemanager, spotifymanager: spotifymanager)
                    }
                    .onChange(of: spotifymanager.palette){oldpalette, newpalette in
                        print(newpalette)
                        blemanager.sendCommand(newpalette)
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
