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
let RESULT_KEY = "result"


typealias DoneHandler = (_ result:[String:Any]?, _ error: Error?) -> Void

class Communicator {

static let BASEURL = "http://class.softarts.cc/FindMyFriends/"
let UPDATEDEVICETOKEN_URL = BASEURL + "updateUserLocation.php?"
let RETRIVE_LOCATION_URL = BASEURL + "queryFriendLocations.php?"

    static let shared = Communicator()
    
    private init(){
    }
    
    func update(completion: @escaping DoneHandler) {
        let urlString = "\(RETRIVE_LOCATION_URL)GroupName=\(GROUPNAME)"
        doPost(urlString: urlString, completion: completion)
    }
    
    func sendLocation(lat: Double, lon: Double, completion: @escaping DoneHandler) {
        let urlString2 = "\(UPDATEDEVICETOKEN_URL)GroupName=\(GROUPNAME)&UserName=\(USER_NAME)&Lat=\(lat)&Lon=\(lon)"
        doPost(urlString: urlString2, completion: completion)
    }
    
    fileprivate func doPost(urlString: String, completion: @escaping DoneHandler) {
        Alamofire.request(urlString, method: .post, encoding: URLEncoding.default).responseJSON { (response) in
            
            self.handleJSON(response: response, completion: completion)
        }
    }
    
    private func handleJSON(response: DataResponse<Any>, completion: DoneHandler) {
        switch response.result {
        case .success(let json):
            //print("Get success response: \(json)")
            
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
