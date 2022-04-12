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
    let uuid: UUID

    var duration: TimeInterval {
        let referenceDate = endDate ?? currentDateProvider.currentDate()
        return referenceDate.timeIntervalSince(startDate)
    }

    private var currentDateProvider: CurrentDateProvider

    // MARK: - Initializer

    init(start: Date, currentDateProvider: CurrentDateProvider = DateProvider.sharedInstance) {
        self.uuid = UUID()
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

// MARK: - Equatable

extension Break: Equatable {

    static func == (lhs: Break, rhs: Break) -> Bool {
        lhs.uuid == rhs.uuid
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
