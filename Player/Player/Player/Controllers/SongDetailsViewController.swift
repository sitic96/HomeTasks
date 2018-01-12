import UIKit

class SongDetailsViewController: UIViewController {

    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var singerNameLabel: UILabel!
    @IBOutlet private weak var albumNameLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!

    var currentSong: Song?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissController))
        self.view.addGestureRecognizer(tapGesture)
        setInfo()
    }

    @objc private func dismissController() {
        let transition = CATransition()
        transition.duration = 1.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }

    private func setInfo() {
        guard let song = currentSong else {
            showAlert(title: ErrorTitles.sorry, text: ErrorMessageBody.noInfo)
            return
        }
        trackNameLabel.text = song.name
        singerNameLabel.text = song.singer
        albumNameLabel.text = song.album
        genreLabel.text = song.primaryGenre
    }
}

extension SongDetailsViewController: CurrentSongChanged {
    func nextSongStarted(_ newSong: Song) {
        currentSong = newSong
        setInfo()
    }
}
