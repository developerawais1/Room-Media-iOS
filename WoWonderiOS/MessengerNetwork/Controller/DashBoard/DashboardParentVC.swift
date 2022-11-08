

import UIKit
import XLPagerTabStrip
import DropDown
import WoWonderTimelineSDK
class DashboardParentVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var nearByBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    private let moreDropdown = DropDown()
    override func viewDidLoad() {
        self.setupUI()
//        view.setNeedsLayout()
//        view.layoutIfNeeded()
        super.viewDidLoad()
        self.backView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)

        self.customizeDropdown()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func nearByPressed(_ sender: Any) {
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
        let storyboard = UIStoryboard(name: "MoreSection", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FindFriendVC") as! FindFriendVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func morePressed(_ sender: Any) {
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
        self.moreDropdown.show()
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
        let Storyboard = UIStoryboard(name: "Search", bundle: nil)
        let vc = Storyboard.instantiateViewController(withIdentifier: "SearchVC") as! UINavigationController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    func customizeDropdown(){
        moreDropdown.dataSource = [NSLocalizedString("Block User List", comment: "Block User List")]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
        //        moreDropdown.bottomOffset = CGPoint(x: 312, y:-270)
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                let storyboard = UIStoryboard(name: "General", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "BlockedUsersVC") as! BlockedUsersVC
                self.navigationController?.pushViewController(vc, animated: true)
                //                let vc = R.storyboard.chat.messengerBlockedUsersVC()
                //                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
                //              let vc = R.storyboard.settings.settingsVC()
                //                self.navigationController?.pushViewController(vc!, animated: true)
            }
            print("Index = \(index)")
        }
        
    }

    private func setupUI() {
        self.navigationController!.navigationBar.tintColor = .hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.searchBtn.tintColor = .white//UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.nearByBtn.tintColor = .white//UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.moreBtn.tintColor = .white
        self.nameLabel.textColor = .white
        self.navigationController!.navigationBar.barTintColor =  UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.appDelegate?.window?.tintColor =  UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.headerView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        
        self.containerView.isScrollEnabled = false
        self.nameLabel.text = ControlSettings.AppName
        settings.style.buttonBarItemBackgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)//.clear
        settings.style.selectedBarBackgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
//        settings.style.buttonBarItemFont =  UIFont(name: "Poppins", size: 15)!
        settings.style.selectedBarHeight = 1
        settings.style.buttonBarMinimumLineSpacing = 0
//        settings.style.buttonBarItemTitleColor = .
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        let color = UIColor.systemGray
        buttonBarView.selectedBar.backgroundColor = .white
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = color
            newCell?.label.textColor = .white//UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
            print("OldCell",oldCell)
            print("NewCell",newCell)
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let chatVC = R.storyboard.chat.chatVC()
        let callVC = R.storyboard.chat.callsVC()
        let ChatGroupVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatGroupvc")
        let pagesVC = R.storyboard.groupsAndPages.pageListVC()
        pagesVC!.user_id = UserData.getUSER_ID()!
        pagesVC!.isOwner = true
        return [chatVC!,ChatGroupVC,pagesVC!,callVC!]
        
    }
}
