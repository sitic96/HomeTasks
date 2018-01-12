import Foundation

protocol CurrentSongChanged: class {
    func nextSongStarted(_ newSong: Song)
}
