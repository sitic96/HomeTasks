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
            DispatchQueue.main.async {
                if let playlist = plst {
                    guard let newViewController = self?.storyboard?
                        .instantiateViewController(withIdentifier: "SearchResultsViewController"),
                        let resultsViewController = newViewController as? SearchResultsViewController else {
                            return
                    }
                    resultsViewController.playlist = playlist
                    self?.navigationController?.pushViewController(resultsViewController, animated: true)
                } else {
                    self?.showAlert(title: .error, text: .downloadError)
                }
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
            searchTextField.resignFirstResponder()
            getSongs(songName: text)
            return false
        }
        return true
    }
}
