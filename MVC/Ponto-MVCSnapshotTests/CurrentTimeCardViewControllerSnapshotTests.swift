//
//  CurrentTimeCardViewControllerSnapshotTests.swift
//  Ponto-MVCSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 03/21/22.
//

import XCTest
import SnapshotTesting
import SnapshotTestingStitch

@testable import Ponto_MVC

class CurrentTimeCardViewControllerSnapshotTests: XCTestCase {

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

    func test_CurrentTimeCardViewController_noTimeCard() throws {
        // Arrange
        let recordMode = false
        let repository = LocalTimeCardRepository(timeCards: [])
        let viewController = CurrentTimeCardViewController(timeCardRepository: repository, currentDateProvider: mockDateProvider)
        let navigationController = UINavigationController(rootViewController: viewController)

        // Act
        _ = viewController.view

        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardViewController_ongoingTimeCardWithoutBreaks() throws {
        // Arrange
        let recordMode = false
        let timeCard = TimeCard(start: mockDateProvider.currentDate(), currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        let viewController = CurrentTimeCardViewController(timeCardRepository: repository, currentDateProvider: mockDateProvider)
        let navigationController = UINavigationController(rootViewController: viewController)

        // Act
        _ = viewController.view

        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardViewController_onABreakTimeCard() throws {
        // Arrange
        let recordMode = false
        let `break` = Break(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                            currentDateProvider: mockDateProvider)
        let timeCard = TimeCard(start: mockDateProvider.currentDate(), breaks: [`break`], currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        let viewController = CurrentTimeCardViewController(timeCardRepository: repository, currentDateProvider: mockDateProvider)
        let navigationController = UINavigationController(rootViewController: viewController)

        // Act
        _ = viewController.view

        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardViewController_ongoingTimeCardWithBreaks() throws {
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
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        try mockDateProvider.updateDate(to: "02/01/97 16:00")
        let viewController = CurrentTimeCardViewController(timeCardRepository: repository, currentDateProvider: mockDateProvider)
        let navigationController = UINavigationController(rootViewController: viewController)

        // Act
        _ = viewController.view

        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardViewController_finishedTimeCardWithoutBreaks() throws {
        // Arrange
        let recordMode = false
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        let viewController = CurrentTimeCardViewController(timeCardRepository: repository, currentDateProvider: mockDateProvider)
        let navigationController = UINavigationController(rootViewController: viewController)

        // Act
        _ = viewController.view

        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

    func test_CurrentTimeCardViewController_finishedTimeCardWithBreaks() throws {
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
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        try mockDateProvider.updateDate(to: "02/01/97 16:20")
        let viewController = CurrentTimeCardViewController(timeCardRepository: repository, currentDateProvider: mockDateProvider)
        let navigationController = UINavigationController(rootViewController: viewController)

        // Act
        _ = viewController.view

        // Make main thread process all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: navigationController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
    }

}
