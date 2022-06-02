//
//  DateExtension.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import Foundation

extension Date {

    var dayComponents: DateComponents {
        Calendar.current.dateComponents([.day, .month, .year], from: self)
    }

}
