//
//  SongService.swift
//  Player
//
//  Created by Sitora on 03.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation

private enum Type: String {
    case audio = ".m4a"
    case image = ".jpg"
}

private enum PossibleURLs: String {
    case basicSearchURL = "https://itunes.apple.com/search?term="
}

private enum SearchType: String {
    case song
    case artist
}

private enum ResultsCount: Int {
    case defaultCount = 25
}

final class SongService {
    private let networkService = NetworkService()

    private func exist(_ song: Song, _ fileTye: Type) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(song.songID)" + fileTye.rawValue) {
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

    private func getSongFromMemory(_ song: Song, _ fileType: Type) -> URL? {
        guard let documentsUrl = try? FileManager.default.url(for: .documentDirectory,
                                                              in: .userDomainMask, appropriateFor: nil,
                                                              create: true) else {
                                                                return nil
        }
        let destination = documentsUrl.appendingPathComponent("\(song.songID)" + fileType.rawValue)
        return destination
    }

    func getSongURL(_ song: Song, completionHandler: @escaping (_ result: URL?) -> Void) {
        if exist(song, .audio) {
            completionHandler(getSongFromMemory(song, .audio))
        } else {
            downloadSong(song) { song in
                completionHandler(song)
            }
        }
    }

    func getImageURL(_ song: Song, completionHandler: @escaping (_ result: Data?) -> Void) {
        networkService.getImage(bigImageURL(small: song.artwork)) { data in
            completionHandler(data)
        }
    }

    // По дефолту api itunes предоставляет обложку в максимальном разрешение 100х100,
    //    для получения изображения лучшего качества нужно заменить в ссылке разрешение на 600х600
    private func bigImageURL(small: URL) -> URL {
        let bigImage = small.relativeString.replacingOccurrences(of: "100x100bb", with: "600x600bb")
        return URL(string: bigImage)!
    }

    func getSongsByName(_ name: String, _ limit: Int?,
                        completionHandler: @escaping (_ songs: Playlist?) -> Void) {
        let url = PossibleURLs.basicSearchURL.rawValue +
            "\(name)&entity=" + SearchType.song.rawValue + "&limit=\(limit ?? ResultsCount.defaultCount.rawValue)"
        search(url: url) { data in
            completionHandler(data)
        }
    }

    func getSongsByArtistName(_ name: String, _ limit: Int?,
                              completionHandler: @escaping (_ songs: Playlist?) -> Void) {
        let url = PossibleURLs.basicSearchURL.rawValue +
            "\(name)&entity=" + SearchType.song.rawValue + "&limit=\(limit ?? ResultsCount.defaultCount.rawValue)"
        search(url: url) { data in
            completionHandler(data)
        }
    }

    func getFavoriteSongs() -> Playlist? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = documentsURL.appendingPathComponent("songs.json")
        do {
            let data = try Data(contentsOf: url, options: [])
            return getSongsFromJSON(json: data)
        } catch {
            return nil
        }
    }

    private func search(url: String,
                        completionHandler: @escaping (_ songs: Playlist?) -> Void) {
        networkService.jsonRequest(url: url) { [weak self] data in
            guard let data = data else {
                return completionHandler(nil)
            }
            completionHandler(self?.getSongsFromJSON(json: data))
        }
    }

    private func getSongsFromJSON(json: Data) -> Playlist? {
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(Result.self, from: json) else {
            return nil
        }
        return Playlist(result.results)
    }
}
