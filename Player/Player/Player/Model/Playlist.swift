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

    init(_ songs: [Song]) {
        songs.forEach { song in
            self.songs.enque(value: song)
        }
    }

    init() {

    }

    func next() -> Song? {
        return songs.peek()
    }

    func insert(_ song: Song) {
        songs.enque(value: song)
    }

    func first() -> Song? {
        return songs.first()
    }

    func shufle() {
        var secondValue: Int
        for var index in (0..<songs.size) {
            secondValue = Int(exactly: arc4random_uniform(UInt32(truncatingIfNeeded: songs.size)))!
            songs.swap(index, secondValue)
        }
    }
}
