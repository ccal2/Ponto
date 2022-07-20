//
//  DateProvider.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 02/13/22.
//

import Foundation

protocol CurrentDateProvider {
    func currentDate() -> Date
}

class DateProvider: CurrentDateProvider {

    static let sharedInstance = DateProvider()

    private init() { }

    func currentDate() -> Date {
        Date()
    }

}
