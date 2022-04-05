//
//  DateHandler.swift
//  WeatherApp
//
//  Created by Dexter Yap on 28/03/2022.
//

import Foundation
// Get the date informations
class DateHandler{
    
    static let stringOffset: Int = 10
    
    //Get Current Date
    static var todaysDate: String{
        return formatDateString(date: Date())
    }
    
    //Get Tomorrow Date
    static var tomorrowsDate: String{
        guard let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {return ""}
        return formatDateString(date: tomorrowDate)
    }
    
    private static func formatDateString(date: Date) -> String {
        let dateString = String(describing: date)
        let endIndex = dateString.index(dateString.startIndex, offsetBy: self.stringOffset)
        return dateString.substring(to: endIndex)
    }
}
