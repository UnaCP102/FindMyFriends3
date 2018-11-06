//
//  FriendsLocationTableViewCell.swift
//  FindMyFriends3
//
//  Created by Una Lee on 2018/10/31.
//  Copyright © 2018 Una Lee. All rights reserved.
//

import UIKit
import MapKit

class FriendsLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var lastupdateDateTimeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    var address: String = ""
    
    
    var friend: FriendItem? {
        
        didSet {
//            let lat = (friend?.lat)!
//            let lon = (friend?.lon)!
//            guard let latDouble = Double(lat) else {
//                print("lat changeDouble Fail")
//                return
//            }
//
//            guard  let lonDouble = Double(lon) else {
//                print("lon changeDobule Fail")
//                return
//            }
            //address = showAddress(lat: latDouble, lon: lonDouble)
            let text = "\(friend!.lat), \(friend!.lon)"
            idLabel.text = friend?.id
            nameLabel.text = friend?.friendName
            locationLabel.text = text
            //locationLabel.text = address
            lastupdateDateTimeLabel.text = friend?.lastUpdateDateTime
        }
    }
    
    func showAddress(lat: Double, lon: Double) -> String {
    let geocoder = CLGeocoder()
        let targetLocatio = CLLocation(latitude: lat, longitude: lon)
    geocoder.reverseGeocodeLocation(targetLocatio) { (plackmarks, error) in
    if let error = error {
    print("goecodeAddressString fail: \(error)")
    return
        }
    // Optional chain 可選鍊
    guard let placemark = plackmarks?.first
    else {
    assertionFailure("plackmarks is empty or nil.")
    return
        }
    print("placemark: \(placemark.postalCode!), \(placemark.thoroughfare!)")
        }
        return address
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
