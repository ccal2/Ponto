//
//  Break.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 02/13/22.
//

import Foundation

class Break {

    // MARK: - Properties

    private(set) var startDate: Date
    private(set) var endDate: Date? = nil
    
    private var currentDateProvider: CurrentDateProvider

    var duration: TimeInterval {
        let referenceDate = endDate ?? currentDateProvider.currentDate()
        return referenceDate.timeIntervalSince(startDate)
    }

    // MARK: - Initializer

    init(start: Date, currentDateProvider: CurrentDateProvider = DateProvider()) {
        self.startDate = start
        self.currentDateProvider = currentDateProvider
    }

    // MARK: - Methods

    func finish() throws {
        guard endDate == nil else {
            throw BreakError.alreadyFinished
        }

        endDate = currentDateProvider.currentDate()
    }

}

// MARK: - Errors

enum BreakError: LocalizedError {
    // Cases
    case alreadyFinished

    // Description
    var errorDescription: String? {
        switch self {
        case .alreadyFinished:
            return NSLocalizedString("The break has already finished", comment: "Error description")
        }
    }

}
