import UIKit

/// Inbox Message Cell
class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
