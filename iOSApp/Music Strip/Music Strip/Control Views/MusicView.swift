//
//  MusicView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/9/25.
//

import SwiftUI

struct MusicView: View {
    @ObservedObject var blemanager: BLEManager
    @ObservedObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var spotifymanager: SpotifyManager
    private var spotify_connected = false
    @State var go_to_control = false
    @State var go_to_settings = false
    init(appState: AppState, ble: BLEManager, spotifymanager: SpotifyManager){
        self.appState = appState
        self.blemanager = ble
        self.spotifymanager = spotifymanager
    }
    
    var body: some View {
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
                                blemanager.sendCommand("spotify:snake")
                                go_to_control = true
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
                        }
                        
                        HStack{
                            VStack{
                                Button {
                                    blemanager.sendCommand("spotify:fade")
                                    go_to_control = true
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
                            
                            VStack{
                                Button {
                                    blemanager.sendCommand("spotify:swap")
                                    go_to_control = true
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
                                .navigationDestination(isPresented: $go_to_control){
                                    DynamicView(appState: appState, ble: blemanager)
                                }
                            
                        }
                        
                    }
                }
                .overlay(alignment: .topTrailing, content: {
                    Button(action: {
                        go_to_settings = true
                    }, label: {
                        Image(systemName: "gearshape.fill")

                    })
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.8))
                    .padding(.all, 8)
                    .background(Circle().fill(.gray.opacity(0.2)))
                    .padding()
                })
                .navigationDestination(isPresented: $go_to_settings){
                    MusicSettingsView(spotifymanager: spotifymanager)
                }
        
    }
}
