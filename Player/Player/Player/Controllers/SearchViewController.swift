import UIKit

final class SearchViewController: UIViewController {

    @IBOutlet private weak var songsCollectionView: UICollectionView!
    @IBOutlet private weak var searchTextField: UITextField!

    private var playlist = Playlist()
    private let networkService = NetworkService()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCollectionView()
    }
}

extension SearchViewController {
    private func prepareCollectionView() {
        songsCollectionView.register(UINib(nibName: "SongCell",
                                           bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
    }

    private func getSongs(songName: String) {
        // TODO remove magic number
        networkService.getSongsByName(songName, 25) { [weak self] plst in
            guard let playlst = plst,
             playlst.size > 0 else {
                return
            }
            self?.playlist = playlst
            DispatchQueue.main.sync {
                self?.songsCollectionView.reloadData()
                self?.searchTextField.isUserInteractionEnabled = true
            }
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            guard let text = searchTextField.text,
                !text.isEmpty else {
                    return false
            }
            searchTextField.isUserInteractionEnabled = false
            playlist.removeAll()
            songsCollectionView.reloadData()
            searchTextField.resignFirstResponder()
            getSongs(songName: text)
            return false
        }
        return true
    }
}

extension SearchViewController: UICollectionViewDataSource,
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
        guard let newViewController = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController"),
            let playerViewController = newViewController as? PlayerViewController else {
                return
        }

        playlist.startIndex(with: indexPath.row)
        playerViewController.playlist = self.playlist
        self.present(playerViewController, animated: true, completion: nil)
    }
}
