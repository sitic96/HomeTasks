//
//  NetworkService.swift
//  Player
//
//  Created by Ситора Гулямова on 29.12.17.
//  Copyright © 2017 Sitora. All rights reserved.
//

import Foundation

private enum PossibleURLs: String {
    case basicSearchURL = "https://itunes.apple.com/search?term="
}

final class NetworkService {
    private let session = URLSession.shared

    func audioFileRequest(url: URL, songId: Int64, completionHandler: @escaping (_ result: URL?) -> Void) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory,
                in: .userDomainMask).first else {
            return completionHandler(nil)
        }
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(String(songId) + "m4a")
        URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
            guard let location = location,
                  error == nil,
                  try FileManager.default.moveItem(at: location, to: destinationUrl) else {
                return completionHandler(nil)
            }
            return completionHandler(destinationUrl)
        }).resume()
    }

    private func request(_ url: URL, completionHandler: @escaping (_ result: Any?) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, _, error) in
            guard error == nil,
                  let usableData = data else {
                return completionHandler(nil)
            }
            completionHandler(usableData)
        }
        task.resume()
    }
}

extension NetworkService {

    // TODO rename
    private func jsonRequest(url: String, completionHandler: @escaping (_ result: [String: Any]?) -> Void) {
        guard let url = URL(string: url) else {
            return completionHandler(nil)
        }
        request(url) { data in
            guard let data = data,
                  let usableData = data as? [String: Any] else {
                return completionHandler(nil)
            }
            completionHandler(usableData)
        }
    }

    func getSongs(name: String, limit: Int?, completionHandler: @escaping (_ playlist: Playlist?) -> Void) {
        var plst: Playlist?
        let group = DispatchGroup()
        let queue = DispatchQueue.global()

        group.enter()
        getSongsByName(name, limit) { songs in
            plst = songs
        }
        group.leave()
        group.notify(queue: queue, execute: {
            completionHandler(plst)
        })
    }

    private func getSongsByName(_ name: String, _ limit: Int?,
                                completionHandler: @escaping (_ songs: Playlist?) -> Void) {
        let url = PossibleURLs.basicSearchURL.rawValue + "\(name)&entity=song&limit=\(String(describing: limit))"
        jsonRequest(url: url) { [weak self] data in
            guard let data = data else {
                return completionHandler(nil)
            }
            completionHandler(self?.getSongsFromJSON(json: NSKeyedArchiver.archivedData(withRootObject: data)))
        }
    }

    private func getSongsFromJSON(json: Data) -> Playlist? {
        let decoder = JSONDecoder()
        guard let songs = try? decoder.decode([Song].self, from: json) else {
            return nil
        }
        return Playlist(songs)
    }
}
