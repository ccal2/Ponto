//
//  TimeCardHistoryViewSnapshotTests.swift
//  Ponto-MVVMSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 29/08/22.
//

import XCTest
import SnapshotTesting
import SnapshotTestingStitch
import SwiftUI

@testable import Ponto_MVVM

class TimeCardHistoryViewSnapshotTests: XCTestCase {

    // MARK: - Properties

    var mockDateProvider: MockDateProvider!
    let runLoopAdditionalTime: TimeInterval = 0.005

    // MARK: - Set up & Tear down

    override func setUpWithError() throws {
        CommonFormatters.shared.locale = Locale(identifier: "en_US")
        mockDateProvider = MockDateProvider()
        try mockDateProvider.updateDate(to: "02/01/97 15:00")
    }

    override func tearDownWithError() throws {
        mockDateProvider = nil
    }

    // MARK: - Tests

    func test_TimeCardHistoryView_noTimeCards() throws {
        // Arrange
        let recordMode = false
        let repository = LocalTimeCardRepository(timeCards: [])
        let viewModel = TimeCardHistoryViewModel(timeCardRepository: repository)
        let view = TimeCardHistoryView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation(embeddedView: AnyView(view))

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_TimeCardHistoryView_someTimeCards() throws {
        // Arrange
        let recordMode = false
        let repository = LocalTimeCardRepository(timeCards: [
            timeCard(forStartDate: mockDateProvider.currentDate(),
                     withBreakStartAfter: 4,
                     breakDuration: 1,
                     endAfter: 9),
            timeCard(forStartDate: mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.daysToSeconds),
                     withBreakStartAfter: 3.5,
                     breakDuration: 1.1,
                     endAfter: 9),
            timeCard(forStartDate: mockDateProvider.currentDate().addingTimeInterval(5 * Constants.TimeConversion.daysToSeconds),
                     withBreakStartAfter: 4,
                     breakDuration: 1,
                     endAfter: 9),
            timeCard(forStartDate: mockDateProvider.currentDate().addingTimeInterval(40 * Constants.TimeConversion.daysToSeconds),
                     withBreakStartAfter: 4.1,
                     breakDuration: 0.9,
                     endAfter: 9.2),
            timeCard(forStartDate: mockDateProvider.currentDate().addingTimeInterval(41 * Constants.TimeConversion.daysToSeconds),
                     withBreakStartAfter: 3.85,
                     breakDuration: 1.2,
                     endAfter: 8.75)
        ])
        try mockDateProvider.updateDate(to: "02/03/97 8:00")
        let viewModel = TimeCardHistoryViewModel(timeCardRepository: repository)
        let view = TimeCardHistoryView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation(embeddedView: AnyView(view))

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    // MARK: - Helpers

    private func timeCard(forStartDate startDate: Date,
                          withBreakStartAfter breakStartHours: Double,
                          breakDuration: Double,
                          endAfter endHours: Double) -> TimeCard {
        assert(endHours > breakStartHours+breakDuration)

        let `break` = Break(start: startDate.addingTimeInterval(breakStartHours * Constants.TimeConversion.hoursToSeconds),
                            end: startDate.addingTimeInterval((breakStartHours+breakDuration) * Constants.TimeConversion.hoursToSeconds),
                            currentDateProvider: mockDateProvider)
        let timeCard = TimeCard(start: startDate,
                                end: startDate.addingTimeInterval(endHours * Constants.TimeConversion.hoursToSeconds),
                                breaks: [`break`],
                                currentDateProvider: mockDateProvider)

        return timeCard
    }

}
