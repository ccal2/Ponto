//
//  PontoViewControllersSnapshotTests.swift
//  Ponto-MVCSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 03/21/22.
//

import XCTest
import SnapshotTesting
import SnapshotTestingStitch

@testable import Ponto_MVC

class PontoViewControllersSnapshotTests: XCTestCase {

    // MARK: - Properties

    var mockDateProvider: MockDateProvider!
    let runLoopAdditionalTime: TimeInterval = 0.002

    // MARK: - Set up & Tear down

    override func setUpWithError() throws {
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
        let viewController = CurrentTimeCardViewController()
        let _ = viewController.view

        // Act

        // Make main thread proccess all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .light, orientation: .landscape)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .dark, orientation: .landscape)
    }

    func test_CurrentTimeCardViewController_ongoingTimeCardWithoutBreaks() throws {
        // Arrange
        let recordMode = false
        let timeCard = TimeCard(start: mockDateProvider.currentDate(), currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        let viewController = CurrentTimeCardViewController(timeCardRepository: repository, currentDateProvider: mockDateProvider)
        let _ = viewController.view

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")

        // Make main thread proccess all operations without having to wait for it
        RunLoop.main.run(until: Date()+runLoopAdditionalTime)

        // Assert
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .light, orientation: .landscape)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .dark, orientation: .landscape)
    }

}
