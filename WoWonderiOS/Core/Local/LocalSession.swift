import WoWonderTimelineSDK
import Foundation
enum UserDefaultsKeys : String {
    case isLoggedIn
    case userID
}

extension UserDefaults{
    //MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        //synchronize()
    }
    
    func isLoggedIn()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: Save User Data
    func setUserSession(value: [String:Any], ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    func getUserSessions(Key:String) -> [String:Any]{
        return (object(forKey: Key) as? [String:Any]) ?? [:]
    }
    func setPassword(value: String, ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    
    func getPassword(Key:String) ->  String{
        return object(forKey: Key)  as?  String ?? ""
    }
//    func setSettings(value:Data?, ForKey:String){
//        set(value, forKey: ForKey)
//        synchronize()
//    }
    
    func setCallLogs(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
    }
    
    func getCallsLogs(Key:String) ->  [Data]{
        return object(forKey: Key)  as?  [Data] ?? []
    }
    
    func setChatColorHex(value: String, ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    
    func getChatColorHex(Key:String) ->  String{
        return object(forKey: Key)  as?  String ?? ""
    }
    
    func setFavorite(value: [String:[Data]], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    func getFavorite(Key:String) ->  [String:[Data]]{
        return ((object(forKey: Key) as? [String:[Data]]) ?? [:])
    }
    
    func setSettings(value:[String:Any]?, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    
    func setConversationTone(value: Bool, ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    
    func getConversationTone(Key:String) ->  Bool{
        return object(forKey: Key)  as?  Bool ?? false
    }
    
    func getSettings(Key:String) ->  Data{
        return (object(forKey: Key)  as?  Data ?? Data())
    }
    func clearUserDefaults(){
        removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    func removeValuefromUserdefault(Key:String){
        removeObject(forKey: Key)
    }
    func setDarkMode(value: Bool, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getDarkMode(Key:String) ->  Bool{
        
        return ((object(forKey: Key) as? Bool) ?? false)!
        
    }
    func setDeviceId(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    func getDeviceId(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    func setConversationToneStatus(value: Bool, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    func getConservationToneStatus(Key:String) ->  Bool{
        
        return ((object(forKey: Key) as? Bool) ?? false)!
        
    }
    func setNotificationStatus(value: Bool, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
    }
    func getNotificationStatus(Key:String) ->  Bool{
        
        return ((object(forKey: Key) as? Bool) ?? false)!
        
    }
    
}
