//
//  CommonFormatters.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import Foundation

class CommonFormatters {

    let durationDateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }()

    let timeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    let shortDayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        if let dateFormat = DateFormatter.dateFormat(fromTemplate: "d MMMM", options: 0, locale: Locale.current) {
            formatter.dateFormat = dateFormat
        }
        return formatter
    }()

    static let shared: CommonFormatters = CommonFormatters()

    private init() { }

}
