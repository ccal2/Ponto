//
//  Constants.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 02/13/22.
//

import Foundation

enum Constants {

    enum TimeConversion {
        static let minutesToSeconds: TimeInterval = 60
        static let hoursToMinutes: TimeInterval = 60
        static let hoursToSeconds: TimeInterval = hoursToMinutes * minutesToSeconds
        static let daysToHours: TimeInterval = 24
        static let daysToSeconds: TimeInterval = daysToHours * hoursToMinutes * minutesToSeconds
    }

    enum ViewSpacing {
        static let small: Double = 8.0
        static let medium: Double = 16.0
        static let big: Double = 24.0
        static let large: Double = 32.0
        static let extraLarge: Double = 64.0
        static let extraExtraLarge: Double = 80.0
    }

    enum ImageName {
        static let startButton: String = "play.circle.fill"
        static let stopButton: String = "stop.circle.fill"
        static let pauseButton: String = "pause.circle.fill"
        static let resumeButton: String = "play.circle.fill"
        static let calendarIcon: String = "calendar"
        static let clockIcon: String = "clock.fill"
    }

    enum CurrentTimeCard {
        static let tabBarTitle: String = NSLocalizedString("Today", comment: "Title of a tab bar item that represents the view for the current time card")
    }

    enum TimeCardDetails {
        static let timeCardSectionRowCount: Int = 2
        static let breakSectionRowCount: Int = 3
        static let durationPlaceholder: String = "00:00:00"
        static let timePlaceholder: String = "--:--"
        static let clockInTimeCellTitle: String = NSLocalizedString("Clock in", comment: "Title of a table view cell to indicate the clock in time")
        static let clockOutTimeCellTitle: String = NSLocalizedString("Clock out", comment: "Title of a table view cell to indicate the clock out time")
        static let numberedBreakSectionHeaderTitle: String = NSLocalizedString("Break %d", comment: "Title of a table view header of a section that represents a break from a time card")
        static let breakStartTimeCellTitle: String = NSLocalizedString("Start", comment: "Title of a table view cell to indicate the start time of a time card's break")
        static let breakEndTimeCellTitle: String = NSLocalizedString("Finish", comment: "Title of a table view cell to indicate the end time of a time card's break")
        static let breakDurationCellTitle: String = NSLocalizedString("Duration", comment: "Title of a table view cell to indicate the duration of a time card's break")
        static let ongoingBreakIndicator: String = NSLocalizedString("ongoing", comment: "Detail of a table view cell to indicate that the time card's break is ongoing")
    }

    enum TimeCardHistory {
        static let screenTitle: String = NSLocalizedString("History", comment: "Title of the screen that shows the list of all time cards previously registered")
        static let emptyHistoryMessage: String = NSLocalizedString("No time card registered yet", comment: "Label in a table view background to indicate there are no records to show")
    }

}
