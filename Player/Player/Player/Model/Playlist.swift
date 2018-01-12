//
//  Playlist.swift
//  Player
//
//  Created by Sitora on 02.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation
final class Playlist {
    private var songs = CircularQueue<Song>()

    var size: Int {
        return songs.size
    }

    init(_ songs: [Song]) {
        songs.forEach { song in
            self.songs.enque(value: song)
        }
    }

    init() {
    }

    func toArray() -> [Song] {
        return songs.itemsArray
    }

    func current() -> Song? {
        return songs.current()
    }

    func next() -> Song? {
        return songs.peek()
    }

    func prev() -> Song? {
        songs.movePointerBack()
        return songs.peek()
    }

    func insert(_ song: Song) {
        songs.enque(value: song)
    }

    func remove(_ song: Song) {
        songs.remove(song)
    }

    func first() -> Song? {
        return songs.first()
    }

    func get(index: Int) -> Song? {
        return songs.get(at: index)
    }

    func removeAll() {
        songs.removeAll()
    }

    func startIndex(with index: Int) {
        songs.changePointerPosition(with: index)
    }
}
