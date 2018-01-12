import UIKit

extension UIViewController {
    func showAlert(title: ErrorTitles, text: ErrorMessageBody) {
        let alert = UIAlertController(title: title.rawValue,
                                      message: text.rawValue,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
