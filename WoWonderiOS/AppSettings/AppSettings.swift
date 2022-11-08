

import Foundation
import UIKit
import WoWonderTimelineSDK
struct AppConstant {
    //cert key for WoWonder
    //Demo Key
    /*
     VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OamJHUnpXVE5vYTJFemFERlhhMmhoWVRBeGNXSkVSbGhoTWxKWVdsWldOR1JHVW5WWGJXeFdWa1JCTlNOV01uUlRVV3N3ZDA1VlZsZFdSVXBQVldwR1YwMUdaSEphUlhCUFZsUlZNVlJWVWtOWlYwWnlWMjVHVlZKc1NubFVWM2h6VG0xRmVsVnJPV2hoZWtWNlZqSjBVMkZ0VmxkaVJsWm9Vak5TVUZsc1ZYZGxRVDA5UURFek1XTTBOekZqT0dJMFpXUm1Oall5WkdRd1pXSm1OMkZrWmpOak0yUTNNelkxT0RNNFlqa2tNVGszTURNeU1UWT0=
     
     */
    //        static let key = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OT2JHdDNXWHBXYkZZeFNrcFpNR2hUVjJ4WmVGTnVUbFZTZWtaUVdrY3hTMVpGT1VWTlJEQTlJMVpITlhkak1rWkdUbFZXVmxaRk5WRldhMVpIVFVaU1ZsVnROVTVOUkZVeFZGVlNRMWxXU2tkalNFcFZVbXhLZFZSVlZUVlNWbHBaVldzNVUwMUdjSHBXUmxaVFUyMVJkMDVVV21sU01uaFFWV3RrYW1WblBUMUFOelkwWW1Jek9EZGpNREZqT1dWbE56azBZbUl3WTJSa01XRTJZalEzWVRVa01UazNNRE15TVRZPQ=="
    
    
    
//    demo
    static let key = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5Ka01XeFdXa1prYTAxcmNFbFZiWEJEVkRGS05tSkVWbHBpUlRCNFdWY3hTbVZWTVVWTlJEQTlJMVpHWTNoU01rVjRZVE5zVm1KWGFHaFZha0p6VFVaU2RXTkZjRTlXVkZVeFZGVlNRMVF4V2tkVGJUbFZVbTFTUjFwWGMzaFdWbVJaVldzNVUxSllRbmhXTVZKTFYyMVdSazlXYUZOV1JVcG9WbXBHZDJSQlBUMUFNak15TkRRME9UTXdNREV5Tm1VM09XVXhaR0U0T1ROa09XUTNZemcyWlRja01qYzJNelUzTWpnPQ=="
}

struct ControlSettings {
    
    static let showSocicalLogin = false
    static let googleClientKey = "497109148599-u0g40f3e5uh53286hdrpsj10v505tral.apps.googleusercontent.com"
    static let googleApiKey = "AIzaSyDAlG53TEdqWnwQ2wXJkC2CBKPyqW7vALU"
    
    static let oneSignalAppId = "7a59ba79-5802-420c-8d4f-cf4546a380a1"
    static let facebookPlacementID = "250485588986218_554026125298828" //Change this ID with your facebook placement ID
    static let addUnitId = "ca-app-pub-3940256099942544/2934735716"
    static let interestialAddUnitId = "ca-app-pub-3940256099942544/4411468910"
    static let BrainTreeURLScheme = "WoWonder-iOS-Timeline.iOS.App.iOS.payments"
    static let paypalAuthorizationToken = "sandbox_zjzj7brd_fzpwr2q9pk2m568s"
    static let agoraCallingToken = "4a4bdbafa8824d899dd85a2e13ce396a"

    static var showFacebookLogin:Bool = false
    static var showGoogleLogin:Bool = false
    static var isShowSocicalLogin:Bool = false
    static var ShowDownloadButton:Bool = true
    static var shouldShowAddMobBanner:Bool = false
    static var interestialCount:Int? = 3
    static var showPaymentVC = true
    static var buttonColor = "#000000"
    static var appMainColor = "#000000"
    //    "#984243"
    
    static let twilloCall = true
    static let agoraCall = true
    
    static let facebookAds = false//true
    static let googleAds = true
    
    static let inviteFriendText = "Please vist our website \(API.baseURL)"

    static let AppName = NSLocalizedString("WoWonder Messenger", comment: "WoWonder Messenger")
    static let WoWonderText = "\(NSLocalizedString("Hi! there i am using", comment: "Hi! there i am using")) \(AppName)"

    
}

