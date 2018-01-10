//
//  SearchResultsViewController.swift
//  Player
//
//  Created by Sitora on 10.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import UIKit

final class SearchResultsViewController: UIViewController {

    @IBOutlet weak var songsCollectionView: UICollectionView!

    var playlist = Playlist()
    private let songService = SongService()
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
    }
}

extension SearchResultsViewController {
    private func prepareCollectionView() {
        songsCollectionView.register(UINib(nibName: "SongCell",
                                           bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
    }
}

extension SearchResultsViewController: UICollectionViewDataSource,
UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlist.size
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =
            songsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let songCell = cell as? SongCell,
            let song = playlist.get(index: indexPath.row) {
            songCell.singer.text = song.singer
            //            TODO add download image
            //            songCell.songImage
            songCell.songName.text = song.name
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playlist.startIndex(with: indexPath.row)
        PlayScreenService.changePlaylist(self.playlist)
        navigationController?.pushViewController(PlayScreenService.playViewController!, animated: true)
    }
}
