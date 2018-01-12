import UIKit

final class FavoriteSongsViewController: UIViewController {
    private var playlist = Playlist()
    @IBOutlet private weak var songsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
        getSavedSongs()
    }

    private func getSavedSongs() {
        DispatchQueue.global(qos: .background).async {
            self.playlist = StorageService.sharedInstance.favoriteSongs
            DispatchQueue.main.async(execute: self.songsCollectionView.reloadData)
        }
    }
}

extension FavoriteSongsViewController: UICollectionViewDataSource,
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
            songCell.singerLabel.text = song.singer
            //            TODO add download image
            //            songCell.songImage
            songCell.songName.text = song.name
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playlist.startIndex(with: indexPath.row)
        PlayScreenService.changePlaylist(self.playlist)
        guard let pVC = PlayScreenService.playViewController else {
            return
        }
        navigationController?.pushViewController(pVC, animated: true)
    }
}

extension FavoriteSongsViewController {
    private func prepareCollectionView() {
        songsCollectionView.register(UINib(nibName: "SongCell",
                                           bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
    }
}
