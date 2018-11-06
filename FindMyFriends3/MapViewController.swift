//
//  MapViewController.swift
//  FindMyFriends3
//
//  Created by Una Lee on 2018/10/30.
//  Copyright © 2018 Una Lee. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var friendMap: MKMapView!
    
    var friendInfo: FriendItem?
    var incomingFriends = [FriendItem]()
    let logManager = LogManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }
    
    func configureView() {
        guard let friend = friendInfo, let friendLocation = friendMap
            else {
                return
        }
        self.title = "\(friend.friendName)"
        guard let lat = Double(friend.lat), let lon = Double(friend.lon)
            else {
                assertionFailure("Invalid lat/lon.")
                return
        }
        let siteCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = siteCoordinate
        annotation.title = self.title
         annotation.subtitle = "\(friend.lastUpdateDateTime)"
        friendLocation.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: siteCoordinate, span: span)
        friendLocation.setRegion(region, animated: true)
    }
}
