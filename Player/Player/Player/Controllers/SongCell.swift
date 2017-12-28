import UIKit

class SongCell: UICollectionViewCell {

    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var singer: UILabel!
    @IBOutlet weak var album: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
