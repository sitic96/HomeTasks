//
//  PlayerViewController.swift
//  Player
//
//  Created by Sitora on 31.12.17.
//  Copyright © 2017 Sitora. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

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
    var playlist = Playlist()
    private var isPlaying = false
    private var liked = false
    private var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        setupSong(playlist.next())
        super.viewDidLoad()
    }

    @IBAction private func stop(_ sender: Any) {
        if isPlaying {
            audioPlayer.pause()
            pauseButton.setImage(#imageLiteral(resourceName:"ic_play_arrow"), for: .normal)
        } else {
            audioPlayer.play()
            pauseButton.setImage(#imageLiteral(resourceName:"ic_pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }

    @IBAction private func searchBySingerName(_ sender: Any) {

    }

    @IBAction private func likeButtonClicked(_ sender: Any) {
        likeButton.setImage(liked ? #imageLiteral(resourceName:"ic_favorite_border") : #imageLiteral(resourceName:"ic_favorite"), for: .normal)
        liked = !liked
    }
}

extension PlayerViewController: AVAudioPlayerDelegate {
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            // TODO add alert
        }
        guard let nextSong = playlist.next() else {
            return
        }
        setupSong(nextSong)
    }

    private func startPlaying() {
        guard let firstSong = playlist.first() else {
            // TODO alert
            return
        }
        setupSong(firstSong)
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
                self?.audioPlayer.prepareToPlay()
                self?.audioPlayer.play()
            } catch {
                print("Unresolved error \(error.localizedDescription)")
            }
        }
        songService.getImageURL(song) { [weak self] data in
            guard let data = data else {
                DispatchQueue.main.async() {
                    self?.songCoverImageView.image = #imageLiteral(resourceName: "ic_play_arrow")
                }
                return
            }
            DispatchQueue.main.async() {
                self?.songCoverImageView.image = UIImage(data: data)
            }
        }
    }
}
