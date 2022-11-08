

import UIKit
import WoWonderTimelineSDK
import OneSignal
import ZKProgressHUD
import ContactsUI
import BSImagePicker
import Async
import Photos

class BaseVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var oneSignalID:String? = ""
    let tempMsg = ["Hi","Hello", "Hello there can we talk?","How you doing", "You there?"]
    var contactNameArray = [String]()
    var contactNumberArray = [String]()
    
    
    //For imagePicker
    var selectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    let imagePicker = ImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneSignalID = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
        print("Current playerId \(oneSignalID)")
        UserDefaults.standard.setDeviceId(value: oneSignalID ?? "", ForKey: "deviceID")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        //..
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        //..
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func convertTime(miliseconds: Int) -> String {
        
        var seconds: Int = 0
        var minutes: Int = 0
        var hours: Int = 0
        var days: Int = 0
        var secondsTemp: Int = 0
        var minutesTemp: Int = 0
        var hoursTemp: Int = 0
        
        if miliseconds < 1000 {
            return ""
        } else if miliseconds < 1000 * 60 {
            seconds = miliseconds / 1000
            return "\(seconds) seconds"
        } else if miliseconds < 1000 * 60 * 60 {
            secondsTemp = miliseconds / 1000
            minutes = secondsTemp / 60
            seconds = (miliseconds - minutes * 60 * 1000) / 1000
            return "\(minutes) minutes, \(seconds) seconds"
        } else if miliseconds < 1000 * 60 * 60 * 24 {
            minutesTemp = miliseconds / 1000 / 60
            hours = minutesTemp / 60
            minutes = (miliseconds - hours * 60 * 60 * 1000) / 1000 / 60
            seconds = (miliseconds - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(hours) hours, \(minutes) minutes, \(seconds) seconds"
        } else {
            hoursTemp = miliseconds / 1000 / 60 / 60
            days = hoursTemp / 24
            hours = (miliseconds - days * 24 * 60 * 60 * 1000) / 1000 / 60 / 60
            minutes = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000) / 1000 / 60
            seconds = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(days) days, \(hours) hours, \(minutes) minutes, \(seconds) seconds"
        }
    }
    
    func showProgressDialog(text: String) {
        ZKProgressHUD.show()
    }
    
    func dismissProgressDialog(completionBlock: @escaping () ->()) {
        ZKProgressHUD.dismiss()
        completionBlock()
        
    }
    
    func setLocalDate(timeStamp: String?) -> String{
        guard let time = timeStamp else { return "" }
        let localTime = Double(time) //else { return ""}
        let date = Date(timeIntervalSince1970: localTime!)
        let format = DateFormatter()
        format.timeZone = .current
        format.dateFormat = "HH:mm"
        let dateString = format.string(from: date)
        return dateString
    }
    
    func fetchContacts(){
        
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        self.contactNameArray.append(contact.givenName)
                        self.contactNumberArray.append(number.stringValue)
                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
                    }
                }
            }
            print(contacts)
        } catch {
            print("unable to fetch contacts")
        }
        
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                image = result ?? UIImage()
            })
            return image
    }
    
    private func CheckForUserCAll(){
        Async.background({
            GetUserListManager.instance.getUserList(user_id: UserData.getUSER_ID() ?? "", session_Token: UserData.getAccess_Token() ?? "") { (success,roomName,callId,senderName,senderProfileImage,callingType,acessToken2, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.agoraCall ?? false)")
                            let alert = UIAlertController(title: NSLocalizedString("Calling", comment: "Calling"), message: NSLocalizedString("someone is calling you", comment: "someone is calling you"), preferredStyle: .alert)
                            if success?.agoraCall == true{
                               
                                let answer = UIAlertAction(title: NSLocalizedString("Answer", comment: "Answer"), style: .default, handler: { (action) in
                                    log.verbose("Answer Call")
                                   let vc = R.storyboard.call.videoCallVC()
                                    self.navigationController?.pushViewController(vc!, animated: true)
                                })
                                let decline = UIAlertAction(title: NSLocalizedString("Decline", comment: "Decline"), style: .default, handler: { (action) in
                                    log.verbose("Call decline")
                                    log.verbose("Room name = \(roomName)")
                                    log.verbose("CallID = \(callId)")
                                })
                                alert.addAction(answer)
                                alert.addAction(decline)
                                self.present(alert, animated: true, completion: nil)
                            }else{
                                alert.dismiss(animated: true, completion: nil)
                                log.verbose("There is no call to answer..")
                            }
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            //self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            //self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            //self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            }
            
        })
        
    }
    
}
