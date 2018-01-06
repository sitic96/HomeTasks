import UIKit

class SongCell: UICollectionViewCell {

    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var singer: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
