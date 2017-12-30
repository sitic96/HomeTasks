//
//  NetworkService.swift
//  Player
//
//  Created by Ситора Гулямова on 29.12.17.
//  Copyright © 2017 Sitora. All rights reserved.
//

import Foundation

private enum PossibleURLs: String {
    case basicSearcURL = "https://itunes.apple.com/search?term="
}

final class NetworkService {
    private let session = URLSession.shared

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

    private func audioFileRequest(url: String, completionHandler: @escaping (_ result: Data?) -> Void) {
        guard let url = URL(string: url) else {
            return
        }
        request(url) { [weak self] data in
            guard let data = data,
            let usableData = data as? Data else {
                return completionHandler(nil)
            }
            
        }
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
    func getSongs(name: String, limit: Int, completionHandler: @escaping (_ song: [Song]?) -> Void) {
        var songs = [Song]()
        let group = DispatchGroup()
        let queue = DispatchQueue.global()

        group.enter()
        getSongsByName(name, limit) { song in
            if let song = song {
                songs = song
            }
        }
        group.leave()
        group.notify(queue: queue, execute: {
            completionHandler(songs)
        })
        //        request(url: PossibleURLs.basicSearcURL.rawValue + "\(name)&entity=song&limit=\(limit)") { [weak self] data in
        //            guard let data = data,
        //                let songs = self?.getSongsFromJSON(json: NSKeyedArchiver.archivedData(withRootObject: data)) else {
        //                    return completionHandler(nil)
        //            }
        //            completionHandler(songs)
        //        }
    }

    func getSongByLink(_ link: String) {

    }

    private func getSongsByName(_ name: String, _ limit: Int, completionHandler: @escaping (_ songs: [Song]?) -> Void) {
        let url = PossibleURLs.basicSearcURL.rawValue + "\(name)&entity=song&limit=\(limit)"
        jsonRequest(url: url) { [weak self] data in
            guard let data = data else {
                return completionHandler(nil)
            }
            completionHandler(self?.getSongsFromJSON(json: NSKeyedArchiver.archivedData(withRootObject: data)))
        }
    }
    private func getSongsFromJSON(json: Data) -> [Song]? {
        let decoder = JSONDecoder()
        guard let songs = try? decoder.decode([Song].self, from: json) else {
            return nil
        }
        return songs
    }
}
