import UIKit

final class SearchResultsViewController: UIViewController {

    @IBOutlet private weak var songsCollectionView: UICollectionView!

    var playlist = Playlist()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
    }
}

extension SearchResultsViewController {
    private func prepareCollectionView() {
        songsCollectionView.register(UINib(nibName: "SongCell",
                                           bundle: Bundle.main),
                                    forCellWithReuseIdentifier: "cell")
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
            songCell.singerLabel.text = song.singer
            songCell.songName.text = song.name
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playlist.startIndex(with: indexPath.row)
        PlayScreenService.changePlaylist(playlist)
        guard let pVC = PlayScreenService.playViewController else {
            return
        }
        navigationController?.pushViewController(pVC, animated: true)
    }
}
