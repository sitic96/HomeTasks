import UIKit

final class SearchViewController: UIViewController {

    @IBOutlet private weak var searchTextField: UITextField!

    private let songService = SongService()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SearchViewController {
    private func getSongs(songName: String) {
        songService.songsByName(songName, nil) { [weak self] plst in
            guard let playlst = plst,
                  playlst.size > 0 else {
                return
            }
            DispatchQueue.main.async {
                self?.searchTextField.isUserInteractionEnabled = true

                guard let newViewController = self?.storyboard?
                        .instantiateViewController(withIdentifier: "SearchResultsViewController"),
                      let resultsViewController = newViewController as? SearchResultsViewController else {
                    return
                }
                resultsViewController.playlist = playlst
                self?.navigationController?.pushViewController(resultsViewController, animated: true)

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
            searchTextField.resignFirstResponder()
            getSongs(songName: text)
            return false
        }
        return true
    }
}
