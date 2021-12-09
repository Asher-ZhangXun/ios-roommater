//
//  Room.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation

struct DormInfo{
    var roomID : String
    var inviteCode : String
    var roomName : String
    var maxMemeber : Int
    var owner : RoommateInfo
    var residents : [RoommateInfo]
    var announcements : [Event]
    var bills : [Bill]
    
    init(data : [String:Any]) {
        if let value = data["roomID"] as? String{
            roomID = value
        }
        
        if let value = data["inviteCode"] as? String{
            inviteCode = value
        }
        
        if let value = data["roomName"] as? String{
            roomName = value
        }
        
        if let value = data["maxRsidents"] as? Int{
            maxMemeber = value
        }
        
        if let value = data["owner"] as? [String:Any]{
            owner = RoommateInfo(data: value)
        }
        
        if let residents = data["residents"] as? [[String:Any]]{
            for res in residents {
                self.residents.append(RoommateInfo(data: res))
            }
        }
    }
}

struct Bill {
    var name: String
    var due : DateFormatter
    var des : String
    var spread : [RoommateInfo : Double]
    var amount : Double
    var isDone : Bool
}

enum EventPriority : Int{
    case Low = 0
    case Normal = 1
    case High = 2
}

struct Time {
    var hour : Int
    var min : Int
    
    init(h : Int, m : Int) {
        hour = h
        min = m
    }
}

struct Schedule {
    var start : Time
    var end : Time
}

struct Event {
    var title : String
    var Description : String
    var schedule : Schedule
    var allDay : Bool
    var participants : RoommateInfo
    var priority : EventPriority
}

enum Day {
    case Mon
    case Tue
    case Wed
    case Thr
    case Fri
    case Sat
    case Sun
}

struct Affair {
    var title : String
    var Description : String
    var time : [Day: Int]
    var participants : RoommateInfo
    var priority : EventPriority
}