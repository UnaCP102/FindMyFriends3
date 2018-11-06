//
//  LogManager.swift
//  FindMyFriends3
//
//  Created by Una Lee on 2018/11/3.
//  Copyright © 2018 Una Lee. All rights reserved.
//

import Foundation
import SQLite

//let communicator = Communicator.shared

struct FriendItem: Codable {
    var id: String
    var friendName: String
    var lat: String
    var lon: String
    var lastUpdateDateTime: String
    
}

class LogManager {
    static let tableName = "friendlocationLog"
    static let friendlistidKey = "friendlistid"
    static let idKey = "id"
    static let friendnameKey = "friendname"
    static let latKey = "lat"
    static let lonKey = "lon"
    static let lastupdatedatetimeKey = "lastupdatedatetime"
    
    var db: Connection!
    var logTable = Table(tableName)
    var friendlistidColumn = Expression<Int64>(friendlistidKey)
    var idColumn = Expression<String>(idKey)
    var friendnameColumn = Expression<String>(friendnameKey)
    var latColumn = Expression<String>(latKey)
    var lonColumn = Expression<String>(lonKey)
    var lastupdatedatetimeColumn = Expression<String>(lastupdatedatetimeKey)
    
    var friendlistIDs = [Int64]()
    
    init() {
        let filemanager = FileManager.default
        let documentsURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURLPath = documentsURL.appendingPathComponent("log.sqlite").path
        var isNewDB = false
        
        if !filemanager.fileExists(atPath: fullURLPath) {
            isNewDB = true
        }
        do {
            db = try Connection(fullURLPath)
        } catch {
            assertionFailure("Fail to create connection.")
            return
        }
        
        if isNewDB {
            do {
                let command = logTable.create { (builder) in
                    builder.column(friendlistidColumn, primaryKey: true)
                    builder.column(idColumn)
                    builder.column(friendnameColumn)
                    builder.column(latColumn)
                    builder.column(lonColumn)
                    builder.column(lastupdatedatetimeColumn)
                }
                try db.run(command)
                print("Log table is created OK.")
            } catch {
                assertionFailure("Fail to create table: \(error)")
            }
        } else {
            do {
                for friend in try db.prepare(logTable) {
                    friendlistIDs.append(friend[friendlistidColumn])
                }
            } catch {
                 assertionFailure("Fail to create table: \(error)")
            }
            print("There are total \(friendlistIDs.count) friendlist in DB.")
        }
    }
    var count: Int {
        return friendlistIDs.count
    }
    
    func append(_ friend: FriendItem) {
        let command = logTable.insert(latColumn <- friend.lat,
                                                                 lonColumn <- friend.lon,
                                                                 idColumn <- friend.id,
                                                                 friendnameColumn <- friend.friendName,
                                                                 lastupdatedatetimeColumn <- friend.lastUpdateDateTime)
        do {
            let newFriendListID = try db.run(command)
            friendlistIDs.append(newFriendListID)
        } catch {
            assertionFailure("Fail to create table: \(error)")
        }
    }
    
    func getFriendLocation(at: Int) -> FriendItem? {
        guard at >= 0 && at < count else {
            assertionFailure("Invalid friend location index.")
            return nil
        }
        let targetFriendID = idColumn
        let results = logTable.filter(idColumn == targetFriendID)
        do {
            guard let friendlocation = try db.pluck(results) else {
                assertionFailure("Fail to get the only one result.")
                return nil
            }
            return FriendItem(id: friendlocation[idColumn],
                                              friendName: friendlocation[friendnameColumn],
                                              lat: friendlocation[latColumn],
                                              lon: friendlocation[lonColumn],
                                              lastUpdateDateTime: friendlocation[lastupdatedatetimeColumn])
        } catch {
            print("Pluck fail: \(error)")
        }
    return nil
    }
}
