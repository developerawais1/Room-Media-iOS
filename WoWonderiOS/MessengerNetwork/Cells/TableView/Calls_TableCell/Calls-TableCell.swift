

import UIKit

class Calls_TableCell: UITableViewCell {
    
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var callLogImage: UIImageView!
    @IBOutlet weak var callLogLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var delegate:SelectContactCallsDelegate!
    var indexPath:Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callLogImage.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.callBtn.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func callPressed(_ sender: Any) {
         self.delegate.selectCalls(index: self.indexPath ?? 0, type: "audio")
    }
}
