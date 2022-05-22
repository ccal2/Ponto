//
//  MockDateProvider.swift
//  Ponto-MVCTests
//
//  Created by Carolina Cruz Agra Lopes on 02/13/22.
//

import Foundation
@testable import Ponto_MVC

class MockDateProvider: CurrentDateProvider {

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy HH:mm"
        return formatter
    }()

    lazy var mockCurrentDate: Date = dateFormatter.date(from: "02/01/97 15:00")!

    func updateDate(to dateString: String) throws {
        guard let newDate = dateFormatter.date(from: dateString) else {
            throw MockDateProviderError.failedConversion(for: dateString)
        }

        mockCurrentDate = newDate
    }

    // MARK: CurrentDateProvider

    func currentDate() -> Date {
        mockCurrentDate
    }

}

// MARK: - Errors

enum MockDateProviderError: LocalizedError {
    // Cases
    case failedConversion(for: String)

    // Description
    var errorDescription: String? {
        switch self {
        case let .failedConversion(for: stringValue):
            return String(format: NSLocalizedString("Failed to convert \"%@\" to Date", comment: "Error description"), stringValue)
        }
    }

}
