//
//  InboxDetailViewController.swift
//  VibesSDKSampleApp
//
//  Created by Moin' Victor on 22/11/2019.
//  Copyright © 2019 Vibes Media. All rights reserved.
//

import UIKit
import VibesPush

/// Inbox Detail
class InboxDetailViewController: UIViewController {

    var inboxMessage: InboxMessage?

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let inboxMessage = inboxMessage {
            self.subjectLabel.text = inboxMessage.subject
            self.contentLabel.text = inboxMessage.content
            let date = inboxMessage.createdAt
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd hh:mm:ss"
            dateLabel.text = dateFormat.string(from: date)
            if let detail = inboxMessage.detail {
                // download image, you can use any library here
                downloadImage(from: URL(string: detail)!, into: self.imageIcon, withIndicator: activityIndicator)
            }
        }
    }

}
