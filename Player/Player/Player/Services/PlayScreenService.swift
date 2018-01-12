import Foundation
import UIKit

final class PlayScreenService {
    static var playViewController: PlayerViewController?
    private static var currentplaylist = Playlist() {
        didSet {
            if playViewController == nil {
                initPlayerVC()
            }
            playViewController?.playlist = currentplaylist
        }
    }

    static func changePlaylist(_ playlist: Playlist) {
        currentplaylist = playlist
    }

    private static func initPlayerVC() {
        guard let pVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else {
            return
        }
        playViewController = pVC
    }
}
