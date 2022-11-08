//
//  BaseViewController.swift
//  Plax
//
//  Created by Awais on 18/05/2021.
//  Copyright © 2021 Codeslu. All rights reserved.
//

import UIKit
enum Storyboards: String{
    case Main = "Main"
}
class BaseViewController: UIViewController,UINavigationControllerDelegate{
    func hideNavigationBar(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    func alert(title:String,message:String, onYes:@escaping(()->Void)){
        let con = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let buyAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            onYes()
        }
        con.addAction(buyAction)
        self.present(con, animated: true, completion: nil)
    }

    func showAlert(title:String,message:String,yesButton:String,noButton:String, onYes:@escaping(()->Void), onNo:@escaping(()->Void)){
        let con = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let buyAction = UIAlertAction(title: yesButton, style: .default) { (action) in
            onYes()
        }
        let noAction =  UIAlertAction(title: noButton, style: .default) { (action) in
            onNo()
        }
        con.addAction(buyAction)
        if !noButton.isEmpty{
            con.addAction(noAction)
        }
        self.present(con, animated: true, completion: nil)
    }
    func pushController(controller toPush:String,storyboard:Storyboards){
        if #available(iOS 13.0, *) {
            let controller = UIStoryboard(name: storyboard.rawValue, bundle:nil).instantiateViewController(identifier: toPush)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = UIStoryboard(name: storyboard.rawValue, bundle:nil).instantiateViewController(withIdentifier: toPush)
            self.navigationController?.pushViewController(controller, animated: true)
        }

    }
    func getControllerRef(controller toPush:String,storyboard:Storyboards) -> UIViewController{
        return UIStoryboard(name: storyboard.rawValue, bundle:nil).instantiateViewController(withIdentifier: toPush)
    }
}

extension NSObject {
    class var id: String {
        return String(describing: self)
    }
}


public class MyUIView:UIView{
    var cornerRadius: CGFloat {
       get {
           return layer.cornerRadius
       }
       set {
           layer.cornerRadius = newValue
           layer.masksToBounds = newValue > 0
       }
   }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.cornerRadius = 15
        self.addShadow(offset: CGSize(width: 1, height: 1), color: UIColor.gray, radius: 5, opacity: 0.5)
      //  self.borderWidth = 0.3
       // self.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        
    }
}
extension UIView {
    func addShadow(offset:CGSize = CGSize(width: 1, height: 1) , color:UIColor = UIColor.gray, radius:CGFloat = 5, opacity:Float = 0.5) {
            layer.masksToBounds = false
            layer.shadowOffset = offset
            layer.shadowColor = color.cgColor
            layer.shadowRadius = radius
            layer.shadowOpacity = opacity
            let backgroundCGColor = backgroundColor?.cgColor
            backgroundColor = nil
            layer.backgroundColor =  backgroundCGColor
        }
    func addLightShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
    }
}
extension UITableView {
    
    public enum EffectEnum {
        case roll
        case LeftAndRight
    }
    
    public func reloadData(effect: EffectEnum) {
        self.reloadData()
        
        switch effect {
        case .roll:
            roll()
            break
        case .LeftAndRight:
            leftAndRightMove()
            break
        }
    }
    
    private func roll() {
        let cells = self.visibleCells
        
        let tableViewHeight = self.bounds.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 2, delay: Double(delayCounter) * 0.035, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
    private func leftAndRightMove() {
        let cells = self.visibleCells
        
        let tableViewWidth = self.bounds.width
        
        var alternateFlag = false
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: alternateFlag ? tableViewWidth : tableViewWidth * -1, y: 0)
            alternateFlag = !alternateFlag
        }
        
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 2, delay: Double(delayCounter) * 0.035, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.width/2 //This will change with corners of image and height/2 will make this circle shape
        self.clipsToBounds = true
    }
}
extension UIView {
    func applyGradient(colors:[CGColor]?) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.colors = colors ?? [UIColor.green, UIColor.white]
        gradient.name = "gradient"
        gradient.cornerRadius = 5
        if layer.sublayers?[0].name != "gradient"{
            layer.insertSublayer(gradient, at: 0)
        }

    }
    func removeGradient(){
        
        let newlayer = CALayer()
        newlayer.backgroundColor = UIColor.white.cgColor
        guard let layers = layer.sublayers else{return}
        for sublayer in layers{
            if sublayer.name == "gradient"{
                layer.replaceSublayer(sublayer, with: newlayer)
            }
        }
    }
}
extension UIView {

    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true

    }
}
