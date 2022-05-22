//
//  Constants.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 02/13/22.
//

import Foundation

enum Constants {

    enum TimeConversion {
        static let minutesToSeconds: TimeInterval = 60
        static let hoursToMinutes: TimeInterval = 60
        static let daysToHours: TimeInterval = 24
    }

    enum ViewSpacing {
        static let small: Double = 8.0
        static let medium: Double = 16.0
        static let large: Double = 32.0
        static let extraLarge: Double = 64.0
        static let extraExtraLarge: Double = 80.0
    }

    enum ImageName {
        static let startButton: String = "play.circle.fill"
        static let stopButton: String = "stop.circle.fill"
        static let pauseButton: String = "pause.circle.fill"
        static let continueButton: String = "play.circle.fill"
    }

    enum TimeCardDetails {
        static let durationPlaceholder: String = "00:00:00"
    }

}
