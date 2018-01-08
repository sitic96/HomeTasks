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
        let destinationUrl = documentsDirectoryURL.appendingPathComponent("\(songId)" + ".m4a")

        URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("audio"),
                let location = location, error == nil
                else { return completionHandler(nil)}

            try? FileManager.default.moveItem(at: location, to: destinationUrl)
            return completionHandler(destinationUrl)
        }).resume()
    }

    private func imageRequest(url: URL, completionHandler: @escaping (_ result: Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                completionHandler(nil)
                print(error?.localizedDescription)
            } else {
                completionHandler(data)
            }
            }.resume()
    }

    private func request(_ url: URL, completionHandler: @escaping (_ result: Data?) -> Void) {
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
    private func jsonRequest(url: String, completionHandler: @escaping (_ result: Data?) -> Void) {
        guard let url = URL(string: url) else {
            return completionHandler(nil)
        }
        print(url)
        request(url) { data in
            guard let data = data else {
                return completionHandler(nil)
            }
            completionHandler(data)
        }
    }

    func getImage(_ link: URL, completionHandler: @escaping (_ result: Data?) -> Void) {
        imageRequest(url: link) { data in
            return completionHandler(data)
        }
    }

    func getSongsByName(_ name: String, _ limit: Int?,
                                completionHandler: @escaping (_ songs: Playlist?) -> Void) {
        let url = PossibleURLs.basicSearchURL.rawValue + "\(name)&entity=song&limit=\(limit ?? 25)"
        jsonRequest(url: url) { [weak self] data in
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
