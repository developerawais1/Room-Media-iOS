
import UIKit
import XLPagerTabStrip
import Async
import SDWebImage
import Alamofire
import SwiftEventBus
import WoWonderTimelineSDK
import GoogleMobileAds
import FBAudienceNetwork

class ChatVC: BaseVC {
    @IBOutlet weak var downTextLabel: UILabel!
    @IBOutlet weak var noMessagesLabel: UILabel!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noChatImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var peopleBtn: UIButton!
    //Ads
    //Google Ads
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    //Facebook Ads
    var fullScreenAd: FBInterstitialAd!
    var bannerAdView: FBAdView!
    
    private var userObject: GetUserListModel.GetUserListSuccessModel?
    private  var refreshControl = UIRefreshControl()
    private var fetchSatus:Bool? = true
    private var timer = Timer()
    private var callId:Int? = 0
    private var callingStatus:String? = ""
    private var callType:String? = ""
    private var friendRequests = [[String:Any]]()
    private var callingAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getRequest()
        //        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
        //            //            self.getRequest()
        //        }
        self.fetchData()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
        }
        
        log.verbose("iosDeviceId = \(AppInstance.instance.profile?.userData?.iosMDeviceID ?? "")")
        if ControlSettings.shouldShowAddMobBanner{
            
            if ControlSettings.googleAds {
                GADInterstitialAd.load()
                
            }else if ControlSettings.facebookAds{
                loadFullViewAdd()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        SwiftEventBus.unregister(self)  
    }
    func CreateAd() -> GADInterstitialAd {
        let interstitial = GADInterstitialAd()
        //               interstitial.load(GADRequest())
        return interstitial
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    
    @IBAction func followingPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MoreSection", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FollowingVC") as! FollowingController
        vc.userId = UserData.getUSER_ID()!
        self.navigationController?.pushViewController(vc, animated: true)
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
        
    }
    func setupUI(){
        self.view.backgroundColor = .hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.noChatImage.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.peopleBtn.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.noMessagesLabel.text = NSLocalizedString("No more Messages", comment: "")
        self.downTextLabel.text = NSLocalizedString("Start new conversations by going to contact", comment: "")
        self.noChatImage.isHidden = true
        self.showStack.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView()
        tableView.register( R.nib.chatsTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chats_TableCell.identifier)
        self.tableView.register(UINib(nibName: "FriendRequestCell", bundle: nil), forCellReuseIdentifier: "FriendRequestcell")
    }
    @objc func refresh(sender:AnyObject) {
        fetchSatus = true
        self.userObject?.users?.removeAll()
        self.friendRequests.removeAll()
        self.tableView.reloadData()
        self.fetchData()
        self.getRequest()
        
    }
    
    private func getRequest(){
        if Connectivity.isConnectedToNetwork(){
            Async.main({
                GetFriendRequestManager.sharedInstance.getFriendRequest { (success, authError, error) in
                    
                    if success != nil{
                        for i in success!.friend_requests{
                            self.friendRequests.append(i)
                        }
                        self.tableView.reloadData()
                    }
                    else if (authError != nil){
                        self.view.makeToast(authError?.errors.errorText)
                    }
                    else if (error != nil){
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            })
        }
        else{
            self.view.makeToast(NSLocalizedString("Internet Error", comment: "Internet Error"))
        }
    }
    
    
    private func fetchData(){
        if fetchSatus!{
            fetchSatus = false
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        }else{
            log.verbose("will not show Hud more...")
        }
        
        Async.background({
            print(UserData.getAccess_Token() )
            GetUserListManager.instance.getUserList(user_id: UserData.getUSER_ID() ?? "", session_Token: UserData.getAccess_Token() ?? "") { (success,roomName,callId,senderName,senderProfileImage,callingType,accessToken2, sessionError, serverError, error)  in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.users ?? nil)")
                            if (success?.users?.isEmpty)!{
                                self.noChatImage.isHidden = false
                                self.showStack.isHidden = false
                                self.refreshControl.endRefreshing()
                            }else {
                                self.noChatImage.isHidden = true
                                self.showStack.isHidden = true
                                self.userObject = success
                                self.tableView.reloadData()
                                log.verbose("Room name = \(roomName)")
                                log.verbose("CallID = \(callId)")
                                log.debug("userList = \(success?.agoraCall ?? false)")
                                self.callId = Int(callId ?? "")
                                let alert = UIAlertController(title: NSLocalizedString("Calling", comment: "Calling"), message: "\(senderName ?? "") sends you an \(callingType) request..", preferredStyle: .alert)
                                if ControlSettings.agoraCall == true && ControlSettings.twilloCall == false{
                                    
                                    if success?.agoraCall == true{
                                        self.callingStatus = "agora"
                                        self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                                        
                                        let answer = UIAlertAction(title: NSLocalizedString("Answer", comment: "Answer"), style: .default, handler: { (action) in
                                            log.verbose("Answer Call")
                                            self.agoraAnswerCall(callID: callId!, senderCalling: senderName ?? "", callingType: callingType ?? "", roomId: roomName ?? "", profileImage: senderProfileImage ?? "")
                                        })
                                        let decline = UIAlertAction(title: NSLocalizedString("Decline", comment: "Decline"), style: .default, handler: { (action) in
                                            self.callingAudioPlayer?.stop()
                                            log.verbose("Call decline")
                                            log.verbose("Room name = \(roomName)")
                                            log.verbose("CallID = \(callId)")
                                            self.agoraDeclineCall(callID: callId!)
                                        })
                                        alert.addAction(answer)
                                        alert.addAction(decline)
                                        self.playReceiveCallingSound()
                                        self.present(alert, animated: true, completion: nil)
                                    }else{
                                        alert.dismiss(animated: true, completion: nil)
                                        log.verbose("There is no call to answer..")
                                    }
                                }else{
                                    self.callingStatus = "twillo"
                                    if success?.videoCall == true{
                                        self.callType = "video"
                                        log.verbose("AccessToken2 = \(accessToken2 ?? "")")
                                        self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                                        
                                        let answer = UIAlertAction(title: NSLocalizedString("Answer", comment: "Answer"), style: .default, handler: { (action) in
                                            log.verbose("Answer Call")
                                            self.TwilloVideoCallAnswer(callID: callId!, senderCalling: senderName ?? "", callingType:"video", roomId: roomName ?? "", profileImage: senderProfileImage ?? "", accessToken2: accessToken2!)
                                        })
                                        let decline = UIAlertAction(title: NSLocalizedString("Decline", comment: "Decline"), style: .default, handler: { (action) in
                                            self.callingAudioPlayer?.stop()
                                            log.verbose("Call decline")
                                            log.verbose("Room name = \(roomName)")
                                            log.verbose("CallID = \(callId)")
                                            self.twilloDeclineVideoCall(callID: callId!)
                                        })
                                        alert.addAction(answer)
                                        alert.addAction(decline)
                                        self.playReceiveCallingSound()
                                        self.present(alert, animated: true, completion: nil)
                                    }else if  success?.audioCall == true{
                                        self.callType = "audio"
                                        self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                                        
                                        let answer = UIAlertAction(title: NSLocalizedString("Answer", comment: "Answer"), style: .default, handler: { (action) in
                                            log.verbose("Answer Call")
                                            
                                            self.twilloAudioCallAnswer(callID: callId!, senderCalling: senderName ?? "", callingType: "audio", roomId: roomName ?? "", profileImage: senderProfileImage ?? "", accessToken2: accessToken2!)
                                        })
                                        let decline = UIAlertAction(title: NSLocalizedString("Decline", comment: "Decline"), style: .default, handler: { (action) in
                                            self.callingAudioPlayer?.stop()
                                            log.verbose("Call decline")
                                            log.verbose("Room name = \(roomName)")
                                            log.verbose("CallID = \(callId)")
                                            self.twilloDeclineAudioCall(callID: callId!)
                                        })
                                        alert.addAction(answer)
                                        alert.addAction(decline)
                                        self.playReceiveCallingSound()
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }else{
                                        alert.dismiss(animated: true, completion: nil)
                                        log.verbose("There is no call to answer..")
                                    }
                                    
                                    
                                }
                                
                                self.refreshControl.endRefreshing()
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
    private func agoraDeclineCall(callID:String){
        self.timer.invalidate()
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            CallManager.instance.agoraCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "decline", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
                
            })
            
        })
    }
    
    private func twilloDeclineVideoCall(callID:String){
        self.timer.invalidate()
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloVideoCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "decline", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
            
            
        })
        
    }
    
    private func twilloDeclineAudioCall(callID:String){
        self.timer.invalidate()
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloAudioCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "decline", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
            
        })
        
    }
    private func agoraAnswerCall(callID:String,senderCalling:String,callingType:String,roomId:String,profileImage:String){
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            CallManager.instance.agoraCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "answer", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.status ?? nil)")
                            if callingType == "video"{
                                let vc  = R.storyboard.call.videoCallVC()
                                vc?.callId = Int(callID)
                                vc?.roomID = roomId
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }else{
                                let vc  = R.storyboard.call.agoraCallVC()
                                vc?.callId = Int(callID)
                                vc?.roomID = roomId
                                vc?.usernameString = senderCalling
                                vc?.profileImageUrlString = profileImage
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
                
            })
            
        })
        
    }
    private func twilloAudioCallAnswer(callID:String,senderCalling:String,callingType:String,roomId:String,profileImage:String, accessToken2: String){
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloVideoCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "answer", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.status ?? nil)")
                            
                            
                            
                            //                            let vc  = R.storyboard.call.agoraCallVC()
                            //                            vc?.callId = Int(callID)
                            //                            vc?.roomID = roomId
                            //                            vc?.usernameString = senderCalling
                            //                            vc?.profileImageUrlString = profileImage
                            //                            self.navigationController?.pushViewController(vc!, animated: true)
                            
                            
                            
                            let vc  = R.storyboard.call.twilloAudioCallVC()
                            //                            vc?.callId = callId
                            ////                            vc?.roomID = RoomId
                            //                            //vc?.usernameString = senderCalling
                            //                            //vc?.profileImageUrlString = profileImage
                            //                            vc?.accessToken = sessionID ?? ""
                            // vc?.usernameLabel.text = user
                            vc?.accessToken = accessToken2
                            vc?.roomId = roomId ?? ""
                            
                            vc?.profileImageUrlString = profileImage
                            vc?.usernameString = senderCalling
                            self.navigationController?.pushViewController(vc!, animated: true)
                            //
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
            
        })
        
    }
    private func TwilloVideoCallAnswer(callID:String,senderCalling:String,callingType:String,roomId:String,profileImage:String,accessToken2:String){
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloVideoCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "answer", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(callID)")
                            if callingType == "video"{
                                //                                let storyboard = UIStoryboard(name: "Call", bundle: nil)
                                //                                let vc  = R.storyboard.call.videoCallVC()
                                //                                vc?.callId = self.callId
                                //                                vc?.roomID = roomId
                                //                                self.navigationController?.pushViewController(vc!, animated: true)
                                
                                if self.navigationController?.viewControllers.last is TwilloVideoCallVC {
                                    log.verbose("Video call controller is already presented")
                                }else {
                                    let vc = R.storyboard.call.twilloVideoCallVC()
                                    vc?.accessToken = accessToken2
                                    vc?.roomId = roomId
                                    self.navigationController?.pushViewController(vc!, animated: true)
                                }
                            }else{
                                let vc  = R.storyboard.call.agoraCallVC()
                                vc?.callId = Int(callID)
                                vc?.roomID = roomId
                                vc?.usernameString = senderCalling
                                vc?.profileImageUrlString = profileImage
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
            
            
        })
        
    }
    private func agoraCheckForAction(callID:Int){
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            CallManager.instance.checkForAgoraCall(user_id: userId, session_Token: sessionID, call_id: callID, call_Type: "", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.callStatus ?? nil)")
                            
                            if success?.callStatus == "declined"{
                                self.dismiss(animated: true, completion: nil)
                                self.timer.invalidate()
                                log.verbose("Call Has Been Declined")
                            }else if success?.callStatus == "answered"{
                                log.verbose("Call Has Been Answered")
                                self.timer.invalidate()
                            }else if  success?.callStatus == "no_answer"{
                                self.dismiss(animated: true, completion: nil)
                                self.timer.invalidate()
                                log.verbose("No Answer")
                            }
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
        })
        
    }
    private func twilloCheckForAction(callID:Int,callType:String){
        let userId = UserData.getUSER_ID() ?? ""
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            TwilloCallmanager.instance.checkForTwilloCall(user_id: userId, session_Token: sessionID, call_id: callID, call_Type: callType, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.callStatus ?? nil)")
                            
                            if success?.callStatus == 400{
                                self.dismiss(animated: true, completion: nil)
                                self.timer.invalidate()
                                log.verbose("Call Has Been Declined")
                            }else if success?.callStatus == 200{
                                log.verbose("Call Has Been Answered")
                                self.timer.invalidate()
                            }else if  success?.callStatus == 300{
                                log.verbose("Calling")
                            }
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            })
        }) 
    }
    
    func playReceiveCallingSound() {
        guard let url = Bundle.main.url(forResource: "mystic_call", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            callingAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            callingAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let aPlayer = callingAudioPlayer else { return }
            aPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func update() {
        if self.callingStatus == "agora"{
            self.agoraCheckForAction(callID: self.callId!)
        }else{
            self.twilloCheckForAction(callID: self.callId!, callType:  self.callType ?? "")
        }
    }
    private func blockUser(userId:String){
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        let sessionToken = UserData.getAccess_Token() ?? ""
        Async.background({
            BlockUsersManager.instanc.blockUnblockUser(session_Token: sessionToken, blockTo_userId: userId, block_Action: "block", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.blockStatus ?? "")")
                            self.view.makeToast(NSLocalizedString("User has been blocked!!", comment: "User has been blocked!!"))
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
                
            })
        })
    }
    private func deleteChat(UserID:String){
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
        let sessionID = UserData.getAccess_Token() ?? ""
        Async.background({
            
            ChatManager.instance.deleteChat(user_id: UserID, session_Token: sessionID, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
                
            })
        })
    }
}
extension ChatVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        //        if self.friendRequests.count > 0{
        //             return 2
        //        }
        //        else{
        //            return 1
        //        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1){
            return self.userObject?.users?.count ?? 0
            
        }
        else{
            if (self.friendRequests.count > 0 ){
                return 1
                
            }
            else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestcell") as! FriendRequestCell
            let index = self.friendRequests[indexPath.row]
            if (self.friendRequests.count == 1){
                cell.image2.isHidden = true
                cell.image3.isHidden = true
                if let pro_url = index["avatar"] as? String{
                    let url = URL(string: pro_url)
                    cell.image1.sd_setImage(with: url, completed: nil)
                }
            }
            else if (self.friendRequests.count == 2){
                cell.image3.isHidden = true
                if let pro_url1 = index["avatar"] as? String{
                    let url = URL(string: pro_url1)
                    cell.image1.sd_setImage(with: url, completed: nil)
                }
                if let pro_url2 = self.friendRequests[1]["avatar"] as? String{
                    let url = URL(string: pro_url2)
                    cell.image1.sd_setImage(with: url, completed: nil)
                }
            }
            else if (self.friendRequests.count == 0){
                print("Nothing")
            }
            else{
                if let pro_url1 = self.friendRequests[0]["avatar"] as? String{
                    let url = URL(string: pro_url1)
                    cell.image1.sd_setImage(with: url, completed: nil)
                }
                if let pro_url2 = self.friendRequests[1]["avatar"] as? String{
                    let url = URL(string: pro_url2)
                    cell.image3.sd_setImage(with: url, completed: nil)
                }
                if let pro_url3 = self.friendRequests[2]["avatar"] as? String{
                    let url = URL(string: pro_url3)
                    cell.image3.sd_setImage(with: url, completed: nil)
                }
                
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chats_TableCell.identifier) as? Chats_TableCell
            let object = self.userObject?.users?[indexPath.row]
            cell?.usernameLabel.text = object?.name ?? ""
            cell?.timeLabel.text = object?.lastseenTimeText ?? ""
            log.verbose("object?.profilePicture = \(object?.avatar)")
            let url = URL.init(string:object?.avatar ?? "")
            cell?.profileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
            cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
            if object?.lastseen == "on"{
                cell?.showOnlineView.backgroundColor = UIColor.hexStringToUIColor(hex: "#39A43E")
            }else{
                cell?.showOnlineView.backgroundColor = UIColor.hexStringToUIColor(hex: "#ECECEC")
            }
            //        cell?.seenCheckImage.image = cell!.seenCheckImage.image?.withRenderingMode(.alwaysTemplate)
            let lightFont = UIFont(name: "Poppins-Regular", size: 17)
            if object?.lastMessage?.toID == AppInstance.instance.profile?.userData?.userID && object?.lastMessage?.fromID == AppInstance.instance.profile?.userData?.userID{
                if object?.lastMessage?.seen == "0" || object?.lastMessage?.seen == ""{
                    cell?.usernameLabel.font = UIFont(name: "Poppins-Regular", size: 17)
                    cell?.messageLabel.font = UIFont(name: "Poppins-Regular", size: 13)
                    //                cell?.seenCheckImage.isHidden = true
                }else{
                    cell?.usernameLabel.font = UIFont(name: "Poppins-Regular", size: 17)
                    cell?.messageLabel.font = UIFont(name: "Poppins-Regular", size: 13)
                    //                cell?.seenCheckImage.isHidden = false
                    //                cell?.seenCheckImage.tintColor = .darkGray
                }
                
            }else if object?.lastMessage?.toID == AppInstance.instance.profile?.userData?.userID && object?.lastMessage?.fromID != AppInstance.instance.profile?.userData?.userID{
                if object?.lastMessage?.seen == "0" || object?.lastMessage?.seen == ""{
                    //                cell?.seenCheckImage.isHidden = false
                    cell?.usernameLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
                    cell?.messageLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
                    //                cell?.seenCheckImage.tintColor = .darkGray
                    
                }else{
                    //                cell?.seenCheckImage.isHidden = false
                    cell?.usernameLabel.font = UIFont(name: "Poppins-Regular", size: 17)
                    cell?.messageLabel.font = UIFont(name: "Poppins-Regular", size: 13)
                    //                cell?.seenCheckImage.tintColor = UIColor.hexStringToUIColor(hex: "#B46363")
                    
                }
            }
            //        cell?.messageLabel.text = object?.lastMessage?.text?.htmlAttributedString  ?? ""
            
            let filename = (object!.lastMessage!.mediaFileName)!
            let lat = Double(object?.lastMessage?.lat ?? "0.0")!
            let long = Double(object?.lastMessage?.long ?? "0.0")!
            if object?.lastMessage?.productId != "0"{
                cell?.messageLabel.text = "Sent Product to you"
            }
            else{
                if object?.lastMessage?.mediaFileName == "image.jpg"{
                    cell?.messageLabel.text = NSLocalizedString("image", comment: "image")
                }
                else if object?.lastMessage?.stickers != ""{
                    cell?.messageLabel.text = NSLocalizedString("GIF", comment: "GIF")
                }
                else if filename.contains(".mp4") == true{
                    cell?.messageLabel.text = NSLocalizedString("video", comment: "video")
                }
                else if filename.contains(".wav") == true{
                    cell?.messageLabel.text = NSLocalizedString("audio", comment: "audio")
                }
                else if lat > 0.0 || long > 0.0{
                    cell?.messageLabel.text = "Location"
                }
                else {
                    cell?.messageLabel.text = object?.lastMessage?.text?.htmlAttributedString  ?? ""
                }
            }
            
            //        if object?.lastMessage?.seen == "0"{
            //            cell?.seenCheckImage.tintColor = .darkGray
            //
            //        }else{
            //            cell?.seenCheckImage.tintColor = UIColor.hexStringToUIColor(hex: "#B46363")
            //        }
            
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if AppInstance.instance.addCount == ControlSettings.interestialCount {
            
            if ControlSettings.googleAds {
                GADInterstitialAd.load()
            }
            else if ControlSettings.facebookAds{
                loadFullViewAdd()
            }
        }
        if (indexPath.section == 0){
            let Storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let vc = Storyboard.instantiateViewController(withIdentifier: "FollowRequestVC") as! FollowRequestController
            vc.friend_Requests = self.friendRequests
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
            let vc = R.storyboard.chat.chatScreenVC()
            vc?.recipientID = self.userObject?.users![indexPath.row].userID ?? ""
            vc!.userObject = self.userObject?.users![indexPath.row]
            vc?.chatColorHex = self.userObject?.users![indexPath.row].chatColor ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let editAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            self.deleteChat(UserID: self.userObject?.users![indexPath.row].userID ?? "")
            
        }
        editAction.backgroundColor = .red
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "More") { (rowAction, indexPath) in
            self.showControls(Index: indexPath.row)
            
        }
        deleteAction.backgroundColor = .lightGray
        
        return [editAction,deleteAction]
    }
    private func showControls(Index:Int){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let viewProfile = UIAlertAction(title: NSLocalizedString("View Profile", comment: "View Profile"), style: .default) { (action) in
            log.verbose("view profile")
            let vc = R.storyboard.chat.viewProfileVC()
            vc?.profileId = self.userObject?.users?[Index].userID ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        let block = UIAlertAction(title: NSLocalizedString("Block", comment: "Block"), style: .default) { (action) in
            log.verbose("message Info")
            self.blockUser(userId:  self.userObject?.users?[Index].userID ?? "")
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(viewProfile)
        alert.addAction(block)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension ChatVC:FBInterstitialAdDelegate{
    //Place your placementID here to see the Facebook ads
    func loadFullViewAdd(){
        fullScreenAd = FBInterstitialAd(placementID: ControlSettings.facebookPlacementID)
        fullScreenAd.delegate = self
        fullScreenAd.load()
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        interstitialAd.show(fromRootViewController: self)
        print("AddLoaded")        
    }
    func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
        
    }
}

extension ChatVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("CHATS", comment: "CHATS"))
    }
}
extension ChatVC: FollowRequestDelegate{
    func follow_request(index: Int) {
        self.friendRequests.remove(at: index)
        self.tableView.reloadData()
    }
}
