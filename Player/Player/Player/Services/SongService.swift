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
        if let pathComponent = url.appendingPathComponent("\(song.songID)" + ".m4a") {
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

    private func downloadSong(_ song: Song, completionHandler: @escaping (_ result: URL?) -> Void) {
        networkService.audioFileRequest(url: song.trackViewUrl, songId: song.songID) { url in
            completionHandler(url)
        }
    }

    private func getFromMemory(_ song: Song) -> URL? {
        guard let documentsUrl = try? FileManager.default.url(for: .documentDirectory,
                                                              in: .userDomainMask, appropriateFor: nil, create: true) else {
            return nil
        }
        // your destination file url
        let destination = documentsUrl.appendingPathComponent("\(song.songID)" + ".m4a")
        //        return Bundle.main.url(forResource: "\(song.songID)", withExtension: ".m4a")
        return destination
    }

    func getSongURL(_ song: Song, completionHandler: @escaping (_ result: URL?) -> Void) {
        if exist(song) {
            completionHandler(getFromMemory(song))
        } else {
            downloadSong(song) { song in
                completionHandler(song)
            }
        }
    }
}
