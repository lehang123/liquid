//
//  Date+dateToString.swift
//  ITProject
//
//  Created by Erya Wen on 2019/10/24.
//  Copyright © 2019 liquid. All rights reserved.
//

import Foundation

extension Date {
    
    ///date separator as from firestore
    public static let   DATE_SEPARATOR : String = "-"
    ///time separator as from firestore
     public static let TIME_SEPARATOR : String = ":"
    ///space separator
    public static let SPACE_SEPARATOR  : String = " "
    
    /// Converts Date to String in "dd/mm/yyyy at HH:MM" format.
    func DateToStringWithTimes() -> String{
        let dateString = self.description
        
        let dateTimeComponents : [String] = (dateString.components(separatedBy: Date.SPACE_SEPARATOR))
       
        
        let yearMonthDate : [String] = dateTimeComponents[0].components(separatedBy: Date.DATE_SEPARATOR)
        let time : [String] = dateTimeComponents[1].components(separatedBy: Date.TIME_SEPARATOR)

        let res = yearMonthDate[2] + Date.DATE_SEPARATOR +  yearMonthDate[1] +  Date.DATE_SEPARATOR + yearMonthDate[0] + " at " + time[0] + Date.TIME_SEPARATOR + time[1]
        return res;
    }
    
    /// Converts Date to String in "dd/mm/yyyy" format.
    func DateToString() -> String{
        let dateTimeComp : [String] = self.description.components(separatedBy: Date.SPACE_SEPARATOR)
          
        let yearMonthDate : [String] = dateTimeComp[0].components(separatedBy: Date.DATE_SEPARATOR)
          
         
           //print("yearMonthDate:",yearMonthDate[2] +  yearMonthDate[1] +  yearMonthDate[0])
        let res = yearMonthDate[2] + Date.DATE_SEPARATOR +  yearMonthDate[1] + Date.DATE_SEPARATOR + yearMonthDate[0]
        return res;
    }
}
