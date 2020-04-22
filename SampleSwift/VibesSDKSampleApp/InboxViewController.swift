import UIKit
import VibesPush

/// Inbox Tab
class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var inboxMessages: [InboxMessage] = []

    var selectedItem: Int?
    private let refreshControl = UIRefreshControl()
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshInboxData(_:)), for: .valueChanged)
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        // remove table view empty cells
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    @objc private func refreshInboxData(_ sender: Any) {
        // Fetch inbox messages
        fetchInboxMessages()
    }

    func fetchInboxMessages() {
        self.refreshControl.beginRefreshing()
        Vibes.shared.fetchInboxMessages { [weak self] inboxMessages, error in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                print("fetchInboxMessages: Result -----===>>>>>>>", inboxMessages)
                print("fetchInboxMessages: Error -----===>>>>>>>", error ?? "[None]")
                if error == nil {
                    self?.inboxMessages = inboxMessages
                    self?.tableView.reloadData()
                } else {
                    // show the error message
                    let alertController = UIAlertController(title: "Inbox Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
                        self?.refreshControl.endRefreshing()
                    }))
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchInboxMessages()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // handle empty state, show message when no data is available
        var numOfSections: Int = 0
        if inboxMessages.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No inbox messages. Pull to fetch messages... "
            noDataLabel.textColor = UIColor.gray
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inboxCell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxTableViewCell
        let inboxMessage = self.inboxMessages[indexPath.row]
        print("------>>>>>>>>", inboxMessages)
        inboxCell.subjectLabel.text = inboxMessage.subject
        inboxCell.contentLabel.text = inboxMessage.content
        let date = inboxMessage.createdAt
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd hh:mm:ss"
        inboxCell.dateLabel.text = dateFormat.string(from: date)
        if let detail = inboxMessage.detail {
            inboxCell.imageWidth.constant = 52
            downloadImage(from: URL(string: detail)!, into: inboxCell.imageIcon, withIndicator: inboxCell.activityIndicator)
        } else {
            inboxCell.imageWidth.constant = 0
        }

        return inboxCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = indexPath.row
        performSegue(withIdentifier: "inbox_detail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "inbox_detail",
            let selectedItem = selectedItem,
            let controller = segue.destination as? InboxDetailViewController {
            controller.inboxMessage = inboxMessages[selectedItem]
        }
    }
}

// Mark: UIViewController Image loading
extension UIViewController {

    /// Get Data
    /// - Parameters:
    ///   - url: The url
    ///   - completion: Completion callbacl
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    /// Download image into URL into image view
    /// - Parameters:
    ///   - url: The url
    ///   - imageView: The image view
    ///   - activityIndicator: Activity indicator to show progress
    func downloadImage(from url: URL, into imageView: UIImageView?, withIndicator activityIndicator: UIActivityIndicatorView?) {
        print("Download Started")
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
                imageView?.image = UIImage(data: data)
            }
        }
    }
}
