import UIKit
import AVFoundation

private enum PlayingState: String {
    case pause
    case playing
    case ready
}

final class PlayerViewController: UIViewController {

    @IBOutlet private weak var songCoverImageView: UIImageView!
    @IBOutlet private weak var lengthProgressBar: UIProgressView!
    @IBOutlet private weak var songNameLabel: UILabel!
    @IBOutlet private weak var singerNameButton: UIButton!
    @IBOutlet private weak var previusButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var volumeSlider: UISlider!
    @IBOutlet private weak var likeButton: UIButton!

    private let songService = SongService()
    private var audioPlayer: AVAudioPlayer?
    private var updater: CADisplayLink! = nil
    private var currentPlayingState = PlayingState.ready
    var playlist = Playlist() {
        didSet {
            restart()
        }
    }

    override func viewDidLoad() {
        setupSong(playlist.next())
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback,
                                                            with: AVAudioSessionCategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    @IBAction private func nextButtonClicked(_ sender: Any) {
        stopPlayer()
        setupSong(playlist.next())
    }

    @IBAction private func prevButtonClicked(_ sender: Any) {
        stopPlayer()
        setupSong(playlist.prev())
    }

    @IBAction private func stop(_ sender: Any) {
        guard let player = audioPlayer else {
            self.showAlert(title: ErrorTitles.sorry.rawValue, text: ErrorMessageBody.playError.rawValue)
            return
        }
        animateCoverImageView()
        if player.isPlaying {
            player.pause()
            currentPlayingState = PlayingState.pause
            pauseButton.setImage(#imageLiteral(resourceName:"ic_play_arrow"), for: .normal)

        } else {
            player.play()
            currentPlayingState = PlayingState.playing
            pauseButton.setImage(#imageLiteral(resourceName:"ic_pause"), for: .normal)
        }
    }

    @IBAction private func volumeSliderValueChanged(_ sender: UISlider) {
        guard let player = audioPlayer else {
            return
        }
        player.volume = sender.value
    }

    @IBAction private func showSongDetailInfo(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 1.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.view.window?.layer.add(transition, forKey: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "SongDetailsViewController")
            as? SongDetailsViewController {
            controller.currentSong = playlist.current()
            controller.modalPresentationStyle = .overCurrentContext
            present(controller, animated: false, completion: nil)
        }
    }

    @IBAction private func likeButtonClicked(_ sender: Any) {
        guard let currentSong = playlist.current() else {
            return
        }
        if currentSong.isLiked {
            StorageService.sharedInstance.remove(currentSong)
            likeButton.setImage(#imageLiteral(resourceName: "ic_favorite_border"), for: .normal)
        } else {
            StorageService.sharedInstance.add(currentSong)
            likeButton.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal)
        }
        currentSong.changeLikeState()
    }
}

extension PlayerViewController {
    private func startPlaying() {
        guard let firstSong = playlist.next() else {
            self.showAlert(title: ErrorTitles.error.rawValue, text: ErrorMessageBody.playError.rawValue)
            return
        }
        setupSong(firstSong)
    }

    func restart() {
        if self.isViewLoaded {
            stopPlayer()
            startPlaying()
        }
    }

    private func stopPlayer() {
        guard let player = audioPlayer else {
            return
        }
        player.stop()
    }

    private func setupSong(_ song: Song?) {
        guard let song = song else {
            return
        }
        self.songNameLabel.text = song.name
        self.singerNameButton.setTitle(song.singer, for: .normal)
        songService.getSongLocalURL(song) { [weak self] data in
            guard let songForPlaying = data else {
                return
            }
            do {
                self?.audioPlayer = try AVAudioPlayer(contentsOf: songForPlaying)
            } catch {
                self?.showAlert(title: ErrorTitles.sorry.rawValue, text: ErrorMessageBody.playError.rawValue)
            }
            guard let player = self?.audioPlayer else {
                return
            }
            player.delegate = self
            self?.setupSongLengthProgressBar()
            player.prepareToPlay()
            if self?.currentPlayingState == PlayingState.playing || self?.currentPlayingState == PlayingState.ready {
                player.play()
                self?.currentPlayingState = PlayingState.playing
            }
        }
        songService.getImageURL(song) { [weak self] data in
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.songCoverImageView.image = #imageLiteral(resourceName: "ic_play_arrow")
                }
                return
            }
            DispatchQueue.main.async {
                self?.songCoverImageView.image = UIImage(data: data)
            }
        }
    }

    private func setupSongLengthProgressBar() {
        updater = CADisplayLink(target: self, selector: #selector(updateSongProgress))
        updater.preferredFramesPerSecond = 20
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }

    @objc private func updateSongProgress() {
        guard let player = audioPlayer else {
            return
        }
        let normalizedTime = Float(player.currentTime / player.duration)
        lengthProgressBar.setProgress(normalizedTime, animated: false)
    }
}

extension PlayerViewController: AVAudioPlayerDelegate {
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let nextSong = playlist.next() else {
            return
        }
        setupSong(nextSong)
    }
}

extension PlayerViewController {
    private func animateCoverImageView() {
        guard let player = audioPlayer else {
            return
        }
        player.isPlaying ? decreaseImageView() : growCoverImageView()
    }

    private func growCoverImageView() {
        UIView.animate(withDuration: 1.5, animations: {() -> Void in
            self.songCoverImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }

    private func decreaseImageView() {
        UIView.animate(withDuration: 1.5, animations: {() -> Void in
            self.songCoverImageView?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        })
    }
}
