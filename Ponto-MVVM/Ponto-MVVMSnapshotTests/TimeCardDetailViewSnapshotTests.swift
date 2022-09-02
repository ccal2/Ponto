//
//  TimeCardDetailViewSnapshotTests.swift
//  Ponto-MVVMSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 29/08/22.
//

import XCTest
import SnapshotTesting
import SnapshotTestingStitch
import SwiftUI

@testable import Ponto_MVVM

class TimeCardDetailViewSnapshotTests: XCTestCase {

    // MARK: - Properties

    var mockDateProvider: MockDateProvider!
    let runLoopAdditionalTime: TimeInterval = 0.003

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

    func test_TimeCardDetailView_timeCardWithoutBreaks() throws {
        // Arrange
        let recordMode = false
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                                currentDateProvider: mockDateProvider)
        let viewModel = TimeCardDetailViewModel(timeCard: timeCard)
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation(embeddedView: AnyView(view))

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_TimeCardDetailView_timeCardWithBreaks() throws {
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
        let viewModel = TimeCardDetailViewModel(timeCard: timeCard)
        let view = TimeCardView(viewModel: viewModel)
        let navigationView = EmbeddedViewInNavigation(embeddedView: AnyView(view))

        // Act
        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewSnapshot(matching: navigationView, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

}