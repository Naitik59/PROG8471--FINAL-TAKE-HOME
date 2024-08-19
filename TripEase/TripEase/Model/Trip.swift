//
//  Trip.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 18/08/24.
//

import Foundation

struct Trip {
    var id: String = UUID().uuidString
    let title: String
    let from: String
    let to: String
    let startDate: Date
    let endDate: Date
    let thingsToDo: String
    
    var startDateStr: String {
        formate(date: startDate)
    }
    
    var endDateStr: String {
        formate(date: endDate)
    }
    
    mutating func mutateID(id: String) {
        self.id = id
    }
    
    func formate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        return "\(day)/\(month)"
    }
}
