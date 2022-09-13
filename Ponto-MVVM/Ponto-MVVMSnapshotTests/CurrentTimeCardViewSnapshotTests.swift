//
//  CurrentTimeCardViewSnapshotTests.swift
//  Ponto-MVVMSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 23/08/22.
//

import XCTest
import SnapshotTesting
import SnapshotTestingStitch
import SwiftUI

@testable import Ponto_MVVM

class CurrentTimeCardViewSnapshotTests: XCTestCase {

    // MARK: - Properties

    var mockDateProvider: MockDateProvider!
    var viewModel: CurrentTimeCardViewModel!
    let runLoopAdditionalTime: TimeInterval = 0.005

    // MARK: - Set up & Tear down

    override func setUpWithError() throws {
        CommonFormatters.shared.locale = Locale(identifier: "en_US")
        mockDateProvider = MockDateProvider()
        viewModel = CurrentTimeCardViewModel(timeCardRepository: LocalTimeCardRepository(), currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:00")
    }

    override func tearDownWithError() throws {
        mockDateProvider = nil
        viewModel = nil
    }

    // MARK: - Tests

    func test_CurrentTimeCardView_noTimeCard() throws {
        // Arrange
        let recordMode = false
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation { AnyView(view) }

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardView_ongoingTimeCardWithoutBreaks() throws {
        // Arrange
        let recordMode = false
        let timeCard = TimeCard(start: mockDateProvider.currentDate(), currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        viewModel.timeCard = timeCard
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation { AnyView(view) }

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardView_onABreakTimeCard() throws {
        // Arrange
        let recordMode = false
        let `break` = Break(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                            currentDateProvider: mockDateProvider)
        let timeCard = TimeCard(start: mockDateProvider.currentDate(), breaks: [`break`], currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        viewModel.timeCard = timeCard
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation { AnyView(view) }

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardView_ongoingTimeCardWithBreaks() throws {
        // Arrange
        let recordMode = false
        // first break: 15:15 - 15:20
        let break1 = Break(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                           end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                           currentDateProvider: mockDateProvider)
        // second break: 15:35 - 15:45
        let break2 = Break(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds),
                           end: mockDateProvider.currentDate().addingTimeInterval(45 * Constants.TimeConversion.minutesToSeconds),
                           currentDateProvider: mockDateProvider)
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 16:00")
        viewModel.timeCard = timeCard
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation { AnyView(view) }

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardView_finishedTimeCardWithoutBreaks() throws {
        // Arrange
        let recordMode = false
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        viewModel.timeCard = timeCard
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation { AnyView(view) }

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardView_finishedTimeCardWithBreaks() throws {
        // Arrange
        let recordMode = false
        // first break: 15:15 - 15:20
        let break1 = Break(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                           end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                           currentDateProvider: mockDateProvider)
        // second break: 15:35 - 15:45
        let break2 = Break(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds),
                           end: mockDateProvider.currentDate().addingTimeInterval(45 * Constants.TimeConversion.minutesToSeconds),
                           currentDateProvider: mockDateProvider)
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 16:20")
        viewModel.timeCard = timeCard
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation { AnyView(view) }

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

}
