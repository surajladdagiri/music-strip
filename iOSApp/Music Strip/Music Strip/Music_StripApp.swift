//
//  Music_StripApp.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//

import SwiftUI

class AppState: ObservableObject {
    enum Page{
        case Bluetooth, ManualControl, Error
    }
    
    
    @Published var currPage: Page = .Bluetooth
}




@main
struct Music_StripApp: App {
    @StateObject var appState: AppState
    @StateObject var blemanager: BLEManager
    @StateObject var spotifymanager = SpotifyManager()
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _blemanager = StateObject(wrappedValue: BLEManager(appState: appState))
        
    }
    var body: some Scene {
        WindowGroup {
            if appState.currPage == .Bluetooth {
                BluetoothView(appState: appState, ble: blemanager)
            }else if appState.currPage == .ManualControl {
                ModeView(appState: appState, ble: blemanager, spotifymanager: spotifymanager)
            }else{
                ErrorView()
            }
        }
    }
}
