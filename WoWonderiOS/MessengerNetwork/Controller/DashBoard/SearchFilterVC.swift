

import UIKit
import TTRangeSlider

class SearchFilterVC: UIViewController,TTRangeSliderDelegate,MessengerSearchDelegate{
    func filterSearch(gender: String, countryId: String, ageTo: String, ageFrom: String, verified: String, status: String, profilePic: String, filterByAge: String) {
                print("anbc")

    }
    @IBOutlet weak var all: UIButton!
    @IBOutlet weak var female: UIButton!
    @IBOutlet weak var male: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageSlider: TTRangeSlider!
    @IBOutlet weak var ageSwitch: UISwitch!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var verified: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var profilePicture: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    
    @IBOutlet weak var filterBtn: UIButton!
    var gender: String? = nil
    var countryId: String? = nil
    var filterbyage: String? = nil
    var age_from: String? = nil
    var age_to: String? = nil
    var verify: String? = nil
    var _status: String? = nil
    var delegate:MessengerSearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.all.backgroundColor =  UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.ageSwitch.thumbTintColor =  UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.filterBtn.backgroundColor =  UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.ageSlider.delegate = self
        self.ageLabel.text = "Age"
        self.ageSwitch.isOn = false
        self.minLabel.isHidden = true
        self.maxLabel.isHidden = true
        self.ageSlider.isHidden = true
    }

    func displayVerified(){
        let alert = UIAlertController(title: "", message: NSLocalizedString("Verified", comment: "Verified"), preferredStyle: .actionSheet)
        alert.setValue(NSAttributedString(string: alert.message ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")

        alert.addAction(UIAlertAction(title: NSLocalizedString("All", comment: "All"), style: .default, handler: { (_) in
              self.verified.text = NSLocalizedString("All", comment: "All")
              self.verify = "all"
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Verified", comment: "Verified"), style: .default, handler: { (_) in
            print("Verified")
            self.verified.text = NSLocalizedString("Verified", comment: "Verified")
            self.verify = "on"
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("UnVerified", comment: "UnVerified"), style: .default, handler: { (_) in
            print("UnVerified")
            self.verified.text = NSLocalizedString("UnVerified", comment: "UnVerified")
            self.verify = "off"

        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: { (_) in
            print("Close")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func displayStatus(){
        let alert = UIAlertController(title: "", message: NSLocalizedString("Status", comment: "Status"), preferredStyle: .actionSheet)
        
        alert.setValue(NSAttributedString(string: alert.message ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: NSLocalizedString("All", comment: "All"), style: .default, handler: { (_) in
            self.status.text = NSLocalizedString("All", comment: "All")
            self._status = "all"
            
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Offline", comment: "Offline"), style: .default, handler: { (_) in
            self.status.text = NSLocalizedString("Offline", comment: "Offline")
            self._status = "off"
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Online", comment: "Online"), style: .default, handler: { (_) in
            self.status.text = NSLocalizedString("Online", comment: "Online")
            self._status = "on"
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func displayProfile(){
        let alert = UIAlertController(title: "", message: NSLocalizedString("Profile Picture", comment: "Profile Picture"), preferredStyle: .actionSheet)
        
        alert.setValue(NSAttributedString(string: alert.message ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("All", comment: "All"), style: .default, handler: { (_) in
            self.profilePicture.text = NSLocalizedString("All", comment: "All")
         }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("YES", comment: "YES"), style: .default, handler: { (_) in
            self.profilePicture.text = NSLocalizedString("YES", comment: "YES")
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .default, handler: { (_) in
            self.profilePicture.text = NSLocalizedString("NO", comment: "NO")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func Switch(_ sender: UISwitch) {
        if sender.isOn == true{
            print("on")
            self.minLabel.isHidden = false
            self.maxLabel.isHidden = false
            self.ageSlider.isHidden = false
            self.ageLabel.text = "Age"
            self.ageSlider.maxValue = 70
            self.ageSlider.minValue = 0
            self.ageSlider.selectedMinimum = 0
            self.ageSlider.selectedMaximum = 70
            self.ageSwitch.thumbTintColor = UIColor.hexStringToUIColor(hex: "#984243")
            self.filterbyage = "yes"
        }
        else {
            print("off")
            self.minLabel.isHidden = true
            self.maxLabel.isHidden = true
            self.ageSlider.isHidden = true
            self.ageLabel.text = "Age"
            self.ageSwitch.thumbTintColor = UIColor.hexStringToUIColor(hex: "#FFFFFF")
            self.filterbyage = "no"
        }
    }
    
    @IBAction func Gender(_ sender: UIButton) {
        if (sender.tag == 0){
            self.all.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
            self.all.setTitleColor(.white, for: .normal)
            self.male.backgroundColor = .white
            self.female.backgroundColor = .white
            self.female.setTitleColor(.black, for: .normal)
            self.male.setTitleColor(.black, for: .normal)
            self.gender = "all"
        }
        else if (sender.tag == 1){
            self.all.backgroundColor = .white
            self.male.backgroundColor = .white
            self.female.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
            self.female.setTitleColor(.white, for: .normal)
            self.all.setTitleColor(.black, for: .normal)
            self.male.setTitleColor(.black, for: .normal)
            self.gender = "female"
        }
        else  {
            self.all.backgroundColor = .white
            self.female.backgroundColor = .white
            self.male.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
            self.male.setTitleColor(.white, for: .normal)
            self.all.setTitleColor(.black, for: .normal)
            self.female.setTitleColor(.black, for: .normal)
            self.gender = "male"
        }
    }
    @IBAction func Properites(_ sender: UIButton) {
        if (sender.tag == 0){
            print("Location")
            let vc = R.storyboard.chat.searchLocationVC()
            vc!.modalTransitionStyle = .coverVertical
            vc!.modalPresentationStyle = .fullScreen
            vc!.delegate = self
            self.present(vc!, animated: true, completion: nil)

        }
        else if (sender.tag == 1){
            displayVerified()
            
        }
        else if (sender.tag == 2){
            displayStatus()
        }
        else {
            displayProfile()
        }
    }
    
    @IBAction func Filter(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.filterSearch(gender: self.gender ?? "", countryId: self.countryId ?? "", ageTo: self.age_to ?? "", ageFrom: self.age_from ?? "", verified: self.verify ?? "", status: self._status ?? "", profilePic: self.profilePicture.text ?? "",filterByAge:self.filterbyage ?? "")
        }
//        let userInfo =  ["gender": self.gender ?? "","country": self.countryId ?? "","verified": self.verify ?? "","status": self._status ?? "","profilePic": self.profilePicture.text!,"filterbyage": self.filterbyage ?? "","age_from":self.age_from ?? "", "age_to": self.age_to ?? "","keyword": ""] as [String : Any]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadFilterData"), object: nil, userInfo: userInfo)
//        self.dismiss(animated: true, completion: nil)
    }
    
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        let min = String(format: "%i",Int(selectedMinimum))
        let max = String(format: "%i",Int(selectedMaximum))
        self.ageLabel.text = "\("Age ")\(min)\(" - ")\(max)"
        self.age_from = min
        self.age_to = max
    }
    
    func locationSearch(location: String, countryId: String) {
        self.location.text = location
        self.countryId = countryId
    }
}
