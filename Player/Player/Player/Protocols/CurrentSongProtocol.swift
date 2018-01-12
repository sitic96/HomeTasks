//
//  CurrentSongChanged.swift
//  Player
//
//  Created by Sitora on 12.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation
protocol CurrentSongChanged: class {
    func nextSongStarted(_ newSong: Song)
}
