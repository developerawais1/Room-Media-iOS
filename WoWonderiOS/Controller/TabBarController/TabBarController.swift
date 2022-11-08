//
//  TabBarViewController.swift
//  InsureTechApp
//
//  Created by Awais on 11/05/2019.
//  Copyright © 2019 Saud. All rights reserved.
//

import UIKit

///Custom class of TabBar, Hide native bar, add custom UI with custom buttons.
class TabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet var customTabView: UIView!
    //Footer icons
    
    @IBOutlet weak var homeFooterIcon: UIButton!
    @IBOutlet weak var menuFooterIcon: UIButton!
    
    //Call this clouser where ever you want to add custom floating options
    static var setIndexOfTabBar : ((_ index: Int) -> Void)? = nil
    static var showTabbar:((_ show:Bool)->Void)? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeShape()
        self.delegate = self
        self.setSelectedState()
        TabBarVC.setIndexOfTabBar = { [weak self] index in
            guard let self = self else {return}
            if index == 0{
                self.homeFooterIcon.tag = 0
                self.buttonPressed(self.homeFooterIcon)
                return
            }else{
                self.selectedIndex = index
            }
        }
        TabBarVC.showTabbar = {[weak self] show in
            self?.customTabView.isHidden = !show
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.removeSeprator()
    }
    deinit {
        print("Releasing memory in Tab bar")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.height = 0
        tabBar.frame.origin.y = view.frame.height - 0
        tabBar.isHidden = true
        
    }

    func setSelectedState(){
        
        self.menuFooterIcon.setImage(UIImage(named: "menuicon"), for: .normal)
        self.homeFooterIcon.setImage(UIImage(named: "homeicon"), for: .normal)

    }

    func removeSeprator(){
        //for iOS 13
        if #available(iOS 13.0, *) { //Hide tabbar top seprator
            let appearance = tabBar.standardAppearance
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            tabBar.standardAppearance = appearance
        } else {
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }
    }


    
    func makeShape(){
        customTabView.layer.cornerRadius = 35
        customTabView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(customTabView)
        NSLayoutConstraint.activate([
            customTabView.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1),
            customTabView.widthAnchor.constraint(equalToConstant: view.frame.size.width-15),
            customTabView.heightAnchor.constraint(equalToConstant: 70)
        ])
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: customTabView.bottomAnchor, multiplier: 1)
            ])
        }
        self.customTabView.layer.shadowColor = UIColor.gray.cgColor
        self.customTabView.layer.shadowOffset = CGSize(width: 0, height: -4.0)
        self.customTabView.layer.shadowRadius = 12.0
        self.customTabView.layer.shadowOpacity = 0.2
        self.customTabView.layer.masksToBounds = false
        
    }


    @IBAction func buttonPressed(_ sender: UIButton) {


        if selectedIndex == sender.tag && sender.tag == 0{
            
            ViewController.pushToController?(ViewController.id, Storyboards.Main)
        }
        if sender.tag == 0{

            self.selectedIndex = sender.tag

            UIView.transition(with: sender, duration: 0.8, options: .transitionFlipFromRight, animations: {[weak self] in
                guard let _ = self else { return }
                self?.homeFooterIcon.alpha = 1
                }, completion: nil)
            UIView.transition(with: menuFooterIcon, duration: 0.2, options: .transitionCrossDissolve, animations: {[weak self] in
                guard let self = self else { return }
                self.menuFooterIcon.setImage(UIImage(named: "menuicon"), for: .normal)
                }, completion: nil)

        }
        if sender.tag == 1{
            ViewController.pushToController?("CreateRoom", Storyboards.Main)
        }
        if sender.tag == 2{

            self.selectedIndex = 1
            UIView.transition(with: sender, duration: 0.8, options: .transitionFlipFromRight, animations: {[weak self] in
                guard let _ = self else { return }
                sender.setImage(UIImage(named: "menuSelected"), for: .normal)
                }, completion: nil)
            self.homeFooterIcon.alpha = 0.5
        }

        
    }
    
    func removeTabbarItemsText() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0);
            }
        }
    }
}

