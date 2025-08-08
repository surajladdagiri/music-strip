//
//  SpotifyManager.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/7/25.
//


import SpotifyiOS

enum SpotifyError: Error {
    case unknown, callback, notinstalled, connection, subscription
}

class SpotifyManager: NSObject, ObservableObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    private var appRemote: SPTAppRemote
    private var accessToken: String = UserDefaults.standard.string(forKey: "accessToken") ?? "UNDEFINED"
    @Published var installed = true
    @Published var failedconnection = false
    @Published var connected = true
    @Published var currAlbum: String = ""
    @Published var currAlbumArt: UIImage? = nil
    private var subscribed = false
    
    let configuration = SPTConfiguration(
        clientID: "1b563173e0f24796a66de09c8e177691",
        redirectURL: URL(string: "musicstrip://callback")!
        )
    override init(){
        self.appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        super.init()
    }
    
    func authorize(){
        if accessToken != "UNDEFINED"{
            return
        }
        self.appRemote.authorizeAndPlayURI("spotify:track:69bp2EbF7Q2rqc5N3ylezZ") { spotifyInstalled in
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
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        connected = false
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        connected = true
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
                        self.currAlbumArt = image
                    }
                }
    }
    
    
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        currAlbum = playerState.track.album.uri
        getAlbumArt(playerState.track)
        print(currAlbum)
    }
    
    
}

