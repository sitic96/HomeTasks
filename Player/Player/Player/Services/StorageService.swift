//
//  StorageService.swift
//  Player
//
//  Created by Sitora on 11.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation
final class StorageService {
    static let sharedInstance = StorageService()
    private let fileName = "songs.json"
    private var savedSongs = Playlist()
    var favoriteSongs: Playlist {
        return savedSongs
    }

    private init() {
        if let songs = read() {
            savedSongs = songs
        }
    }

    private func save() -> Bool {
        guard let url = getDocumentsURL() else {
            return false
        }
        let completeURL = url.appendingPathComponent(fileName)
        do {
            let data = try JSONEncoder().encode(savedSongs.toArray())
            try data.write(to: completeURL, options: [])
            return true
        } catch {
            return false
        }
    }

    func add(_ song: Song) -> Bool {
        savedSongs.insert(song)
        return save()
    }

    func read() -> Playlist? {
        guard let url = getDocumentsURL() else {
            return nil
        }
        let completeURL = url.appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: completeURL, options: [])
            let result = try JSONDecoder().decode([Song].self, from: data)
            savedSongs = Playlist(result)
            return savedSongs
        } catch {
            return nil
        }
    }

    func remove(_ song: Song) {
        savedSongs.remove(song)
        removeResourceFromDisk(song)
        save()
    }

    private func removeResourceFromDisk(_ song: Song) {
        let fileManager = FileManager.default
        guard let documentsUrl =  getDocumentsURL() else {
            return
        }
        let audioPath = documentsUrl.appendingPathComponent("\(song.id)"+".m4a")
        let imagePath = documentsUrl.appendingPathComponent("\(song.id)"+".jpg")
        try? fileManager.removeItem(at: audioPath)
        try? fileManager.removeItem(at: imagePath)
    }

    func getDocumentsURL() -> URL? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url
    }
}
