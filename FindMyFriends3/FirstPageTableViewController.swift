//
//  FirstPageTableViewController.swift
//  FindMyFriends3
//
//  Created by Una Lee on 2018/10/30.
//  Copyright © 2018 Una Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstPageTableViewController: UITableViewController,  CLLocationManagerDelegate,  MKMapViewDelegate {
    
    @IBOutlet weak var mainMapView: MKMapView!
    
    let communicator = Communicator.shared
    let locationManager = CLLocationManager()
    var friendLocation = [FriendItem]()
    var friend: FriendItem?
    let logManager = LogManager()
  
    
  
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Ask Permission
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Execute moveAndZoomMap() after 3.0 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showFriendLocation()
            self.moveAndZoomMap()
            
        }
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        showFriendLocation()
    }
    
    func showFriendLocation () {
        communicator.update { (result, error) in
            if let error = error {
                print("showFriendLocation error\(error)")
                return
            }
            guard let result = result else {
                print("result is nil.")
                return
            }
            print("Retrive Friend Locatio OK.")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
            else  {
                    print("Fail to generate jsonData.")
                    return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(RetriveResult.self, from: jsonData) else {
                print("Fail to decoder jsonData.")
                return
            }
            print("resultObject: \(resultObject)")
            guard let friends = resultObject.friends, !friends.isEmpty else {
                print("friends is nil or empty.")
                return
            }

            self.friendLocation = friends
            for friend in friends {
                self.logManager.append(friend)
            }
            self.tableView.reloadData()      //要記得更新，不然TableView跑不出來～！！
        }
    }



    
    func moveAndZoomMap(){
        guard let location = locationManager.location else {
            print("Location is not ready.")
            return
        }
        // Move and zoom the map.
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01 )
        //如果想要看更大的範圍，可以將latitudeDelta和longitudeDelta的值(基本上同步更換)，設定為0.02, 0.03...等放大，以此列推
        
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mainMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            //取得user最後的位置資訊
            assertionFailure("Invalid coordinate or location.")
            //assertionFailure可以用在debug上
            return
        }
        communicator.sendLocation(lat: coordinate.latitude, lon: coordinate.longitude) { (result, error) in
            if let error = error {
                // nil在這一層已經檢查了
                print("Send text error \(error)")
                return
            }
            //這層用！是確定不會是 nil
            print("Send text OK: \(result!)")
        }
        print("Current Location: \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.friendLocation.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendsLocationTableViewCell
        
        let friend = self.friendLocation[indexPath.row]
        cell.friend = friend
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFriendLocation" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let person = friendLocation[indexPath.row]
                let controller = segue.destination as!  MapViewController
                controller.friendInfo = person
                
            }
        }
    }
  
    
   
    
    struct  RetriveResult: Codable {
        var result: Bool
        var friends: [FriendItem]?
        
        enum CodingKeys: String, CodingKey {
            case result = "result"
            case friends = "friends"
            
        }
    }
}
  




