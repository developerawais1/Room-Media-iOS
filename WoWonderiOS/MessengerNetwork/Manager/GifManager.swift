//
//  GifManager.swift
//  WoWonder
//
//  Created by Muhammad Haris Butt on 11/3/20.
//  Copyright © 2020 ScriptSun. All rights reserved.
//

import Foundation
import Alamofire
import WoWonderTimelineSDK

class MessengerGIFManager{
    
    static let instance = MessengerGIFManager()
    
    func getGIFS(limit:Int,offset:Int, completionBlock: @escaping (_ Success:MessengerGifModel.GIFSuccessModel?, Error?) ->()){
        
        let params = [
            API.Params.api_key: APIClient.SERVER_KEY.Server_Key,
            API.Params.q: limit
            ] as [String : Any]
        
        AF.request(APIClient.GIFs.GIFsApi, method: .get, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
         
                let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                let result = try! JSONDecoder().decode(MessengerGifModel.GIFSuccessModel.self, from: response.data!)
                completionBlock(result,nil)

            }else{
                print("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,response.error)
            }
        }
    }
}
