//
//  BreakTests.swift
//  Ponto-MVCTests
//
//  Created by Carolina Cruz Agra Lopes on 02/13/22.
//

import XCTest

@testable import Ponto_MVC

class BreakTests: XCTestCase {

    // MARK: - Properties

    var mockDateProvider: MockDateProvider!

    // MARK: - Set up & Tear down

    override func setUpWithError() throws {
        mockDateProvider = MockDateProvider()
        try mockDateProvider.updateDate(to: "02/01/97 15:00")
    }

    override func tearDownWithError() throws {
        mockDateProvider = nil
    }

    // MARK: - Tests

    // MARK: duration

    func test_duration_withoutEndDate() throws {
        // Arrange
        let workBreak = Break(start: mockDateProvider.currentDate(),
                              currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")

        // Assert
        XCTAssertEqual(workBreak.duration, 15 * Constants.TimeConversion.minutesToSeconds)
    }

    func test_duration_withEndDate() throws {
        // Arrange
        let workBreak = Break(start: mockDateProvider.currentDate(),
                              end: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")

        // Assert
        XCTAssertEqual(workBreak.duration, 15 * Constants.TimeConversion.minutesToSeconds)
    }

    // MARK: finish

    func test_finish_withoutEndDate_updatesEndDate() throws {
        // Arrange
        let workBreak = Break(start: mockDateProvider.currentDate(),
                              currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try workBreak.finish()
        try mockDateProvider.updateDate(to: "02/01/97 15:20")

        // Assert
        XCTAssertEqual(workBreak.endDate, mockDateProvider.dateFormatter.date(from: "02/01/97 15:15"))
    }

    func test_finish_withEndDate_throwsErrorAlreadyFinished() throws {
        // Arrange
        let workBreak = Break(start: mockDateProvider.currentDate(),
                              end: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        // Assert
        XCTAssertThrowsError(try workBreak.finish()) { error in
            XCTAssertEqual(error as? BreakError, .alreadyFinished)
        }
    }

}
