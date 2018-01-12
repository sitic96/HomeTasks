//
//  SongService.swift
//  Player
//
//  Created by Sitora on 03.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation

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

    func getResourceLocalURL(_ song: Song,
                             _ resourceType: ResourceType,
                             completionHandler: @escaping (_ result: URL?) -> Void) {
        if exist(song.id, resourceType) {
            completionHandler(getResourceFromMemory(song.id, resourceType))
        } else {
            downloadResource(for: song, resourceType) { song in
                completionHandler(song)
            }
        }
    }

    private func exist(_ resourceID: Int64, _ fileType: ResourceType) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(resourceID)" + fileType.rawValue) {
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

    private func getResourceFromMemory(_ resourceID: Int64, _ fileType: ResourceType) -> URL? {
        guard let localURL = StorageService.sharedInstance.getDocumentsURL() else {
            return nil
        }

        let destination = localURL.appendingPathComponent("\(resourceID)" + fileType.rawValue)
        return destination
    }

    private func downloadResource(for song: Song,
                                  _ resourceType: ResourceType,
                                  completionHandler: @escaping (_ result: URL?) -> Void) {
        switch resourceType {
        case .audio:
            networkService.audioDownloadRequest(url: song.trackViewUrl, songId: song.id) { url in
                completionHandler(url)
            }
        case .image:
            networkService.dataRequest(url: bigImageURL(small: song.artwork)) { data in
                guard let data = data,
                    let localURL = StorageService.sharedInstance.getDocumentsURL() else {
                        return completionHandler(nil)
                }
                let filePath = localURL.appendingPathComponent("\(song.id)" + ".jpg")
                do {
                    try data.write(to: filePath)
                } catch {
                    return completionHandler(nil)
                }
                completionHandler(filePath)
            }
        }
    }

    // По дефолту api itunes предоставляет обложку в максимальном разрешении 100х100,
    //    для получения изображения лучшего качества нужно заменить в ссылке разрешение на 600х600
    private func bigImageURL(small: URL) -> URL {
        let bigImage = small.relativeString.replacingOccurrences(of: "100x100bb", with: "600x600bb")
        return URL(string: bigImage)!
    }
}
extension SongService {
    func getSongsByName(_ name: String,
                        _ limit: Int?,
                        completionHandler: @escaping (_ songs: Playlist?) -> Void) {
        guard let correctURL = encodeURL(from: name) else {
            return
        }
        let url = PossibleURLs.basicSearchURL.rawValue +
            "\(correctURL)&entity=" + SearchType.song.rawValue + "&limit=\(limit ?? ResultsCount.defaultCount.rawValue)"
        searchSong(url: url) { data in
            completionHandler(data)
        }
    }

    private func encodeURL(from string: String) -> String? {
        return string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    private func searchSong(url: String,
                            completionHandler: @escaping (_ songs: Playlist?) -> Void) {
        guard let correctURL = URL(string: url) else {
            return
        }
        networkService.dataRequest(url: correctURL) { [weak self] data in
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
