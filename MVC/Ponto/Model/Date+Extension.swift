//
//  Date+Extension.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import Foundation

extension Date {

    var dayComponents: DateComponents {
        Calendar.current.dateComponents([.calendar, .day, .month, .year], from: self)
    }

    var monthComponents: DateComponents {
        Calendar.current.dateComponents([.calendar, .month, .year], from: self)
    }

}
