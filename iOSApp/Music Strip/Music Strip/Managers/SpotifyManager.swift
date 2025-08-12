//
//  SpotifyManager.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/7/25.
//


import SpotifyiOS
import SwiftUI
import ColorThiefSwift
import AVFoundation

enum SpotifyError: Error {
    case unknown, callback, notinstalled, connection, subscription
}
enum Algorithm {
    case kmeans, mmcq
}

class SpotifyManager: NSObject, ObservableObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    @Published var appRemote: SPTAppRemote
    private var accessToken: String = UserDefaults.standard.string(forKey: "accessToken") ?? "UNDEFINED"
    @Published var installed = true
    @Published var failedconnection = false
    @Published var connected = true
    @Published var connectedOnce = false
    @Published var currAlbum: String = ""
    @Published var currAlbumArt: UIImage? = nil
    private var currTrack: String = UserDefaults.standard.string(forKey: "currTrack") ?? "spotify:track:6r3duEAfFTH83DuoywkG20"
    @Published var currTitle = UserDefaults.standard.string(forKey: "currTitle") ?? "Feelings by Lauv"
    private var subscribed = false
    @Published var numColors = 7
    @Published var palette = ""
    @Published var duplicates = false
    @Published var algorithm = Algorithm.mmcq
    private var imagemanager = ImageManager()
    
    let configuration = SPTConfiguration(
        clientID: "1b563173e0f24796a66de09c8e177691",
        redirectURL: URL(string: "musicstrip://callback")!
        )
    override init(){
        self.appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        super.init()
    }
    
    func authorize(){
        if appRemote.isConnected{
            return
        }
        //69bp2EbF7Q2rqc5N3ylezZ
        subscribed = false
        self.appRemote.authorizeAndPlayURI(currTrack, asRadio: false, additionalScopes: ["user-read-currently-playing"]) { spotifyInstalled in
            if !spotifyInstalled {
                self.installed = false
            }
        }
        self.appRemote.delegate = self
    }
    
    func handleOpenURL(_ url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
            appRemote.connect()
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(error_description)
        }
    }
    
    
    
    
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?){
        failedconnection = true
        connected = false
        print("Failed Connection!!")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        connected = false
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        connected = true
        connectedOnce = true
        appRemote.playerAPI?.delegate = self
        if !subscribed{
            appRemote.playerAPI?.subscribe(toPlayerState: { result, error in
                if let error = error {
                    print("Subscription failed: \(error.localizedDescription)")
                } else {
                    print("Subscribed successfully")
                    self.subscribed = true
                }
            })
        }
    }
    
    private func getAlbumArtHelper(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void){
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize(width: 1000, height: 1000)) { (image, error) in
                    guard error == nil else {
                        print("Error fetching album art: \(error!.localizedDescription)")
                        return
                    }
                    
                    if let image = image as? UIImage {
                        callback(image)
                    }
                }
    }
    
    func getAlbumArt(_ track: SPTAppRemoteTrack){
        getAlbumArtHelper(track) { image in
                    DispatchQueue.main.async {
                        withAnimation{
                            self.currAlbumArt = image
                            print("Using \(self.numColors) colors")
                            if self.algorithm == .mmcq{
                                print("Using Color Thief")
                                self.palette = "spotifypalette:"+self.imagemanager.getPaletteColorThief(image: image, numberOfColors: self.numColors, duplicates: self.duplicates)
                            }
                            else {
                                print("Using K-Means")
                                self.palette = "spotifypalette:"+self.imagemanager.getPaletteKMeans(image: image, numberOfColors: self.numColors, duplicates: self.duplicates)
                            }
                        }
                    }
                }
    }
    
    
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        if currAlbum != playerState.track.album.uri {
            currTrack = playerState.track.uri
            currAlbum = playerState.track.album.uri
            getAlbumArt(playerState.track)
            currTitle = "\(playerState.track.name) by \(playerState.track.artist.name)"
            print(currTitle)
            UserDefaults.standard.set(currTitle, forKey: "currTitle")
            UserDefaults.standard.set(currTrack, forKey: "currTrack")
        }
    }
    
    
}

