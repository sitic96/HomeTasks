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
    private var songProgress = CADisplayLink()
    weak var delegate: CurrentSongChanged?
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
        } catch {
            showAlert(title: .error, text: .playError)
        }
    }

    @IBAction private func clickedNextButton(_ sender: Any) {
        stopPlayer()
        setupSong(playlist.next())
    }

    @IBAction private func clickedPrevButton(_ sender: Any) {
        stopPlayer()
        setupSong(playlist.prev())
    }

    @IBAction private func clickedStopButton(_ sender: Any) {
        guard let player = audioPlayer else {
            showAlert(title: ErrorTitles.sorry, text: ErrorMessageBody.playError)
            return
        }
        animateCoverImageView()
        if player.isPlaying {
            player.pause()
            currentPlayingState = PlayingState.pause
            pauseButton.setImage(#imageLiteral(resourceName: "ic_play_arrow"), for: .normal)

        } else {
            player.play()
            currentPlayingState = PlayingState.playing
            pauseButton.setImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
        }
    }

    @IBAction private func changedVolumeSliderValue(_ sender: UISlider) {
        guard let player = audioPlayer else {
            return
        }
        player.volume = sender.value
    }

    @IBAction private func showSongDetailInfo(_ sender: Any) {
        let customTransition = CATransition()
        customTransition.duration = 1.5
        customTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        customTransition.type = kCATransitionFade
        view.window?.layer.add(customTransition, forKey: nil)
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SongDetailsViewController")
        as? SongDetailsViewController {
            controller.currentSong = playlist.current()
            controller.modalPresentationStyle = .overCurrentContext
            delegate = controller
            present(controller, animated: false, completion: nil)
        }
    }

    @IBAction private func clickedLikeButton(_ sender: Any) {
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
            showAlert(title: ErrorTitles.error, text: ErrorMessageBody.playError)
            return
        }
        setupSong(firstSong)
    }

    func restart() {
        if isViewLoaded {
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
        prepareUIForNextSong(song)
        songService.resourceLocalURL(song, withType: .audio) { [weak self] data in
            guard let songForPlaying = data,
                  let player = try? AVAudioPlayer(contentsOf: songForPlaying) else {
                self?.showAlert(title: ErrorTitles.error, text: ErrorMessageBody.downloadError)
                return
            }
            player.delegate = self
            self?.audioPlayer = player
            self?.setupSongLengthProgressBar()
            player.prepareToPlay()
            if self?.currentPlayingState == PlayingState.playing || self?.currentPlayingState == PlayingState.ready {
                player.play()
                self?.currentPlayingState = PlayingState.playing
            }
        }
        songService.resourceLocalURL(song, withType: .image) { [weak self] data in
            guard let data = data,
                  let image = try? UIImage(data: Data(contentsOf: data)) else {
                DispatchQueue.main.async {
                    self?.songCoverImageView.image = #imageLiteral(resourceName: "ic_play_arrow")
                }
                return
            }
            DispatchQueue.main.async {
                self?.songCoverImageView.image = image
            }
        }
    }

    private func prepareUIForNextSong(_ song: Song) {
        delegate?.nextSongStarted(song)
        songNameLabel.text = song.name
        singerNameButton.setTitle(song.singer, for: .normal)
        StorageService.sharedInstance.favoriteSongs.contains(song) ?
                likeButton.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal) : likeButton.setImage(#imageLiteral(resourceName: "ic_favorite_border"), for: .normal)
    }

    private func setupSongLengthProgressBar() {
        songProgress = CADisplayLink(target: self, selector: #selector(updateSongProgress))
        songProgress.preferredFramesPerSecond = 20
        songProgress.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
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
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            self.songCoverImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }

    private func decreaseImageView() {
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            self.songCoverImageView?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        })
    }
}
