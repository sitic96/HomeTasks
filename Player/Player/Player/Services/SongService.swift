//
//  SongService.swift
//  Player
//
//  Created by Sitora on 03.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation

final class SongService {
    private let networkService = NetworkService()

    private func exist(_ song: Song) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(String(song.songID) + ".m4a") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    private func downloadSong(_ song: Song, completionHandler: @escaping (_ result: URL?) -> Void) -> URL? {
        networkService.audioFileRequest(url: song.previewLink, songId: song.songID) { fileURL in
            completionHandler(fileURL)
        }
    }

    private func getFromMemory(_ song: Song) -> URL? {
        return Bundle.main.url(forResource: String(song.songID), withExtension: "m4a")
    }

    func getSongURL(_ song: Song) -> URL? {
        if exist(song) {
            return getFromMemory(song)
        } else {
            downloadSong(song) { data in
                return data
            }
        }
    }
}
