//
//  FriendDownload.swift
//  FindMyFriend2
//
//  Created by Una Lee on 2018/10/29.
//  Copyright © 2018 Una Lee. All rights reserved.
//

import Foundation
import Alamofire

// JSON Keys
let GROUPNAME = "cp102"
let USER_NAME = "Una"

let USERNAME_KEY = "UserName"
let GROUPNAME_KEY = "GroupName"
let DEVICETOKEN_KEY = "DeviceToken"
let DATA_KEY = "data"
let LAT_KEY = "Lat"
let LON_KEY = "Lon"
//let LOCATION_KEY = "Location"
let RESULT_KEY = "result"

typealias DoneHandler = (_ result:[String:Any]?, _ error: Error?) -> Void

class Communicator {

static let BASEURL = "http://class.softarts.cc/FindMyFriends/"
let UPDATEDEVICETOKEN_URL = BASEURL + "updateUserLocation.php?"
let RETRIVE_LOCATION_URL = BASEURL + "queryFriendLocations.php?"

    static let shared = Communicator()
    
    private init(){
    }
    
    func update(deviceToken: String, completion: @escaping DoneHandler) {
    let parameters = [USERNAME_KEY:USER_NAME,
                                  DEVICETOKEN_KEY: deviceToken,
                                  GROUPNAME_KEY:GROUPNAME]
        
        doPost(urlString: UPDATEDEVICETOKEN_URL, parameters: parameters, completion: completion)
    }
    
    func sendLocation(location data: String, completion: @escaping DoneHandler) {
        let parameters = [USERNAME_KEY: USER_NAME,
                          LAT_KEY: data, LON_KEY: data,
                          GROUPNAME_KEY: GROUPNAME]
        
        doPost(urlString: UPDATEDEVICETOKEN_URL, parameters: parameters, completion: completion)
    }
    
    fileprivate func doPost(urlString: String,
                            parameters: [String: Any],
                            completion: @escaping DoneHandler) {
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let finalParamters = [DATA_KEY: jsonString]
        
        //以下方式都可使用
        // URLEncoding.default: data=......
        // JSONEncoding.default {"data":"..."}
        // let header = ["AuthorizarionKey":"..."]
        Alamofire.request(urlString, method: .post, parameters: finalParamters, encoding: URLEncoding.default).responseJSON { (response) in
            
            self.handleJSON(response: response, completion: completion)
        }
    }
    
    fileprivate func doPost(urlString: String,
                            parameters: [String: Any],
                            data: Data,
                            completion: @escaping DoneHandler) {
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        Alamofire.upload(multipartFormData: { (formData) in
            formData.append(jsonData, withName: DATA_KEY)
            formData.append(data, withName: "Lon")
            formData.append(data, withName: "Lat")
        }, to: urlString, method: .post) { (encodingResult) in
            switch encodingResult {
            case .success(let request, _, _):
                print("Post Encoding OK.")
                request.responseJSON { (response) in
                    self.handleJSON(response: response, completion: completion)
                }
            case .failure(let error):
                print("Post Encoding fail: \(error)")
                completion(nil, error)
                
            }
        }
    }
    
    private func handleJSON(response: DataResponse<Any>, completion: DoneHandler) {
        switch response.result {
        case .success(let json):
            print("Get success response: \(json)")
            
            guard let finalJson = json as? [String: Any] else {
                let error = NSError(domain: "Invalid JSON object.", code:-1, userInfo: nil)
                completion(nil, error)
                return
            }
            guard let result = finalJson[RESULT_KEY] as? Bool, result == true else {
                let error = NSError(domain: "Server respond false or not result.", code: -1, userInfo: nil)
                completion(nil, error)
                return
            }
            completion(finalJson, nil)
            
        case .failure(let error):
            print("Server respond error: \(error)")
            completion(nil, error)
        }
    }
}
