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
    private var playlist: Playlist?
    private var isPlaying = false
    private var liked = false
    private var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func stop(_ sender: Any) {
        if isPlaying {
            audioPlayer.pause()
            pauseButton.setImage(#imageLiteral(resourceName:"ic_play_arrow"), for: .normal)
        } else {
            audioPlayer.play()
            pauseButton.setImage(#imageLiteral(resourceName:"ic_pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }

    @IBAction func searchBySingerName(_ sender: Any) {

    }

    @IBAction func likeButtonClicked(_ sender: Any) {
        likeButton.setImage(liked ? #imageLiteral(resourceName:"ic_favorite_border") : #imageLiteral(resourceName:"ic_favorite"), for: .normal)
        liked = !liked
    }
}

extension PlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag {
            // TODO add alert
        }
        guard let plst = playlist,
              let nextSong = plst.next() else {
            return
        }
        setupSong(nextSong)
    }

    private func startPlaying() {
        guard let plst = playlist,
              let firstSong = plst.first() else {
            // TODO alert
            return
        }
        setupSong(firstSong)
    }

    private func setupSong(_ song: Song) {
        guard let songForPlaying = songService.getSongURL(song) else {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioPlayer = AVAudioPlayer(contentsOf: songForPlaying)
        } catch {
            print("error")
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}
