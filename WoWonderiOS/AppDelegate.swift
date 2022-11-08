
import UIKit
import CoreData
import Reachability
import IQKeyboardManager
import FBSDKLoginKit
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import OneSignal
import WoWonderTimelineSDK
import GoogleMobileAds
import Kingfisher
import Braintree
import Paystack
import SwiftyBeaver
import Async
import Reachability
import SwiftEventBus

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let status = Reach().connectionStatus()
    var isInternetConnected = Connectivity.isConnectedToNetwork()
    
    var reachability  = try! Reachability()
    
    let hostNames = ["google.com", "google.com", "google.com"]
    var hostIndex = 0
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /* Location Services */
        startHost(at: 0)
        ApplicationDelegate.initializeSDK(nil)
        UIApplication.shared.statusBarStyle = .lightContent

        /* Init Swifty Beaver */
        let console = ConsoleDestination()
        let file = FileDestination()
        log.addDestination(console)
        log.addDestination(file)
        
        ServerCredentials.setServerDataWithKey(key: AppConstant.key)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        AppInstance.instance.locationManager = CLLocationManager()
        AppInstance.instance.locationManager.requestAlwaysAuthorization()
        AppInstance.instance.locationManager .requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled())
        {
            
            AppInstance.instance.locationManager.delegate = self
            AppInstance.instance.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            AppInstance.instance.locationManager.requestAlwaysAuthorization()
            AppInstance.instance.locationManager.startUpdatingLocation()
        }else{
            
            
        }
        Paystack.setDefaultPublicKey("sk_test_de7eb730d9a831dfbfc6b3e86c0609ed5e7eb5e2")
        BTAppContextSwitcher.setReturnURLScheme(ControlSettings.BrainTreeURLScheme)
        
        //        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:"",PayPalEnvironmentSandbox:"AYQj_efvWzS7BgDU42nwInlwmetwd3ZT5WloT2ePnfinLw59GcR_EzEhnG8AtRBp9frGuvs09HsKagKJ"])
        
        
        IQKeyboardManager.shared().isEnabled = true
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,kOSSettingsKeyInAppLaunchURL: false]
        
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: ControlSettings.oneSignalAppId,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
        print("Current playerId \(userId)")
        UserDefaults.standard.setDeviceId(value: userId ?? "", ForKey: "deviceID")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if isAppAlreadyLaunchedOnce(){
            //            let data = UserDefaults.standard.getSettings(Key: APIClient.LOCAL.siteSetting)
            //            let settingsData = try? PropertyListDecoder().decode(Get_Site_SettingModel.Site_Setting_SuccessModel.self ,from: data)
            self.getSettings()
            //            AppInstance.instance.siteSettings = settingsData
            
        }else{
            self.getSettings()
            //               AppInstance.instance.siteSettings = UserDefaults.standard.getSettings(Key: APIClient.LOCAL.siteSetting)
            //            self.getSettings()
        }
        GIDSignIn.sharedInstance().clientID = ControlSettings.googleClientKey
        GMSServices.provideAPIKey(ControlSettings.googleApiKey)
        GMSPlacesClient.provideAPIKey(ControlSettings.googleApiKey)
        //        GMSPlacesClient.provideAPIKey("AIzaSyDo-tKjkOFkb5yl2n_dxPNJngDdFWNrFMk") Preivous
        //        Get_Site_Setting_Data.sharedInstance.load_Site_Setting_Data()
        Get_Site_Setting_Data.sharedInstance.fetchData()
        if (UserData.getUSER_ID() != nil)  {
            print(UserData.getUSER_ID())
            getProfile()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //            let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabbarVC")
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "SplashVC")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            return true
            
        }
        else {
            
            let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "FirstVc")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            return true
            
        }
    }
    private func getProfile(){
        switch status {
        case .unknown, .offline:
            break;
        case .online(.wwan),.online(.wiFi):
            DispatchQueue.main.async {
                FetchUserManager.instance.fetchProfile { (success, authError, error) in
                    if success != nil {
                        AppInstance.instance.profile = success
                        UserData.setUSER_NAME(AppInstance.instance.profile?.userData?.name)
                        UserData.setWallet(AppInstance.instance.profile?.userData?.wallet)
                        UserData.SetImage(AppInstance.instance.profile?.userData?.avatar)
                        UserData.SetisPro(AppInstance.instance.profile?.userData?.isPro)
                    }
                    else if authError != nil {
                    }
                    else if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func getSettings(){
        switch status {
        case .unknown, .offline:
            break;
        case .online(.wwan),.online(.wiFi):
            DispatchQueue.main.async {
                GetSiteSettingManager.sharedInstance.getSiteSetting { (success, authError, error) in
                    if (success != nil){
                        //                        let objectToEncode = success
                        //                        let data = try? PropertyListEncoder().encode(objectToEncode)
                        //
                        //                        UserDefaults.standard.setSettings(value: data, ForKey: APIClient.LOCAL.siteSetting)
                        
                        AppInstance.instance.siteSettings  = success!.config 
                    }
                }
            }
        }
    }
    //    private func getSettings(){
    //        switch status {
    //        case .unknown, .offline:
    //            break;
    //        case .online(.wwan),.online(.wiFi):
    //            DispatchQueue.main.async {
    //                Get_Site_Setting_Manager.sharedInstance.get_Site_Setting { (success, authError, error) in
    //                    if success != nil {
    //
    //                        let objectToEncode = success
    //                        let data = try? PropertyListEncoder().encode(objectToEncode)
    //
    //                        UserDefaults.standard.setSettings(value: data, ForKey: APIClient.LOCAL.siteSetting)
    //
    //                        AppInstance.instance.siteSettings  = success
    //                    }
    //                    else if authError != nil {
    //                    }
    //                    else if error != nil {
    //                        print(error?.localizedDescription)
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme?.localizedCaseInsensitiveCompare(ControlSettings.BrainTreeURLScheme) == .orderedSame {
            
            return BTAppContextSwitcher.handleOpenURL(url)
        }
        else{
            let handled: Bool = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
            // Add any custom logic here.
            return handled;GIDSignIn.sharedInstance().handle(url)
        }
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        let cache = ImageCache.default
        // Memory image expires after 10 minutes.
        //        cache.memoryStorage.config.expiration = .seconds(1)
        //
        //        // Disk image never expires.
        //        cache.diskStorage.config.expiration = .seconds(1)
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "WoWonderiOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func startHost(at index: Int) {
        stopNotifier()
        setupReachability(hostNames[index], useClosures: false)
        startNotifier()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.startHost(at: (index + 1) % 3)
        }
    }
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability:  Reachability?
        if let hostName = hostName {
            reachability = try! Reachability(hostname: hostName)
            
        } else {
            reachability = try! Reachability()
            
        }
        self.reachability = try! reachability ??  Reachability.init()
        
        
        if useClosures {
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    
    func startNotifier() {
        do {
            try reachability.startNotifier()
        } catch {
            
            return
        }
    }
    
    func stopNotifier() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        //        reachability = nil
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        Async.main({
            let reachability = note.object as! Reachability
            switch reachability.connection {
            case .wifi:
                log.debug("Reachable via WiFi")
                self.isInternetConnected = true
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED)
            case .cellular:
                log.debug("Reachable via Cellular")
                self.isInternetConnected = true
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED)
                
            case .none:
                log.debug("Network not reachable")
                self.isInternetConnected = false
                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED)
            default:
                print("Nothing")
            }
        })
    }
    
    
}

extension AppDelegate: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let position = manager.location?.coordinate
        AppInstance.instance.locationManager.stopUpdatingLocation()
        AppInstance.instance.latitude = Double(position!.latitude)
        AppInstance.instance.longitude = Double(position!.longitude)
        print("Latitude = \(AppInstance.instance.latitude)")
        print("Longitude = \(AppInstance.instance.longitude)")
    }
}
