import UIKit

class SongCell: UICollectionViewCell {

    @IBOutlet private weak var songImage: UIImageView!
    @IBOutlet private weak var songName: UILabel!
    @IBOutlet private weak var singer: UILabel!
    @IBOutlet private weak var album: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
