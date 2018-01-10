//
//  PlayerViewController.swift
//  Player
//
//  Created by Sitora on 31.12.17.
//  Copyright © 2017 Sitora. All rights reserved.
//

import UIKit
import AVFoundation

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
    @IBOutlet private weak var minProgressBarLabel: UILabel!
    @IBOutlet private weak var maxProgressBarLabel: UILabel!

    private let songService = SongService()
    var playlist = Playlist() {
        didSet {
            restart()
        }
    }
    private var audioPlayer = AVAudioPlayer()
    private var updater: CADisplayLink! = nil
    private var isDataLoaded = false

    override func viewDidLoad() {
        setupSong(playlist.next())
        super.viewDidLoad()
    }

    @IBAction private func nextButtonClicked(_ sender: Any) {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        setupSong(playlist.next())
    }

    @IBAction private func prevButtonClicked(_ sender: Any) {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        setupSong(playlist.prev())
    }

    @IBAction private func stop(_ sender: Any) {
        animateCoverImageView()
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            pauseButton.setImage(#imageLiteral(resourceName:"ic_play_arrow"), for: .normal)

        } else {
            audioPlayer.play()
            pauseButton.setImage(#imageLiteral(resourceName:"ic_pause"), for: .normal)
        }
    }

    @IBAction private func volumeSliderValueChanged(_ sender: UISlider) {
        audioPlayer.volume = sender.value
    }

    @IBAction private func searchBySingerName(_ sender: Any) {
        guard let singerID = playlist.current()?.singerID else {
            return
        }
        songService.getSongsByArtistID(singerID, nil) { [weak self] data in
            guard let newViewController =
                self?.storyboard?.instantiateViewController(withIdentifier: "SearchResultsViewController"),
                let resultsViewController = newViewController as? SearchResultsViewController else {
                    return
            }
            if let playlist = data {
                resultsViewController.playlist = playlist
                self?.navigationController?.pushViewController(resultsViewController, animated: true)
            }
        }
    }

    @IBAction private func likeButtonClicked(_ sender: Any) {
        guard let currentSong = playlist.current() else {
            return
        }
        likeButton.setImage(currentSong.isLiked ? #imageLiteral(resourceName:"ic_favorite_border") : #imageLiteral(resourceName:"ic_favorite"), for: .normal)
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
            if isDataLoaded {
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                }
            }
            startPlaying()
        }
    }

    private func setupSong(_ song: Song?) {
        guard let song = song else {
            return
        }
        self.songNameLabel.text = song.name
        self.singerNameButton.setTitle(song.singer, for: .normal)
        songService.getSongURL(song) { [weak self] data in
            guard let songForPlaying = data else {
                return
            }
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                self?.audioPlayer = try AVAudioPlayer(contentsOf: songForPlaying)
                self?.audioPlayer.delegate = self
                self?.setupSongProgressBar()
                self?.audioPlayer.prepareToPlay()
                self?.audioPlayer.play()
                self?.isDataLoaded = true
            } catch {
                self?.showAlert(title: ErrorTitles.sorry.rawValue, text: ErrorMessageBody.playError.rawValue)
                print("Unresolved error \(error.localizedDescription)")
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

    private func setVolume() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(true)
        volumeSlider.value = audioSession.outputVolume
    }

    private func setupSongProgressBar() {
        updater = CADisplayLink(target: self, selector: #selector(updateSongProgress))
        updater.preferredFramesPerSecond = 20
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        DispatchQueue.main.async {
            self.maxProgressBarLabel.text = "\(Float(self.audioPlayer.duration).toString())"
        }
    }

    @objc private func updateSongProgress() {
        let normalizedTime = Float(audioPlayer.currentTime / audioPlayer.duration)
        lengthProgressBar.setProgress(normalizedTime, animated: false)
        DispatchQueue.main.async {
            self.minProgressBarLabel.text =
                "\(Float(self.audioPlayer.duration - self.audioPlayer.currentTime).toString())"
        }
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
        audioPlayer.isPlaying ? decreaseImageView() : growCoverImageView()
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
