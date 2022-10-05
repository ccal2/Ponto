//
//  TimeCardTests.swift
//  Ponto-MVCTests
//
//  Created by Carolina Cruz Agra Lopes on 03/21/22.
//

import XCTest

@testable import Ponto_MVC

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class TimeCardTests: XCTestCase {

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

    // MARK: initial state

    func test_initialState_ongoing_withoutBreaks() throws {
        // Arrange

        // Act
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Assert
        XCTAssertEqual(timeCard.state, .ongoing)
        XCTAssertEqual(timeCard.breaks, [])
        XCTAssertNil(timeCard.endDate)
    }

    func test_initialState_ongoing_withBreaks() throws {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(45 * Constants.TimeConversion.minutesToSeconds))

        // Act
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Assert
        XCTAssertEqual(timeCard.state, .ongoing)
        XCTAssertEqual(timeCard.breaks, [break1, break2])
        XCTAssertNil(timeCard.endDate)
    }

    func test_initialState_onABreak() throws {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - ongoing
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))

        // Act
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Assert
        XCTAssertEqual(timeCard.state, .onABreak)
        XCTAssertEqual(timeCard.breaks, [break1, break2])
        XCTAssertNil(timeCard.endDate)
    }

    func test_initialState_finished_withoutBreaks() throws {
        // Arrange
        // finish time: 16:00
        let endDate = mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds)

        // Act
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: endDate,
                                currentDateProvider: mockDateProvider)

        // Assert
        XCTAssertEqual(timeCard.state, .finished)
        XCTAssertEqual(timeCard.breaks, [])
        XCTAssertEqual(timeCard.endDate, endDate)
    }

    func test_initialState_finished_withBreaks() throws {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        // finish time: 16:00
        let endDate = mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds)

        // Act
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: endDate,
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Assert
        XCTAssertEqual(timeCard.state, .finished)
        XCTAssertEqual(timeCard.breaks, [break1, break2])
        XCTAssertEqual(timeCard.endDate, endDate)
    }

    // MARK: duration

    func test_duration_whenStateIsOngoing_withoutBreaks() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")

        // Assert
        XCTAssertEqual(timeCard.duration, 15 * Constants.TimeConversion.minutesToSeconds)
    }

    func test_duration_whenStateIsOngoing_withBreaks() throws {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(45 * Constants.TimeConversion.minutesToSeconds))
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Act
        // start - current date: 15:00 - 16:00
        try mockDateProvider.updateDate(to: "02/01/97 16:00")

        // Assert
        XCTAssertEqual(timeCard.duration, 45 * Constants.TimeConversion.minutesToSeconds)
    }

    func test_duration_whenStateIsFinished_withoutBreaks() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")

        // Assert
        XCTAssertEqual(timeCard.duration, 15 * Constants.TimeConversion.minutesToSeconds)
    }

    func test_duration_whenStateIsFinished_withBreaks() throws {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(45 * Constants.TimeConversion.minutesToSeconds))
        // finish time: 16:00
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 16:20")

        // Assert
        XCTAssertEqual(timeCard.duration, 45 * Constants.TimeConversion.minutesToSeconds)
    }

    func test_duration_whenStateIsOnABreak() throws {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - ongoing
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Act
        // start - current date: 15:00 - 15:40
        try mockDateProvider.updateDate(to: "02/01/97 15:40")

        // Assert
        XCTAssertEqual(timeCard.duration, 30 * Constants.TimeConversion.minutesToSeconds)
    }

    // MARK: startBreak

    func test_startBreak_whenStateIsOngoing_addsNewBreakAndUpdatesStateToOnABreak() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()
        try mockDateProvider.updateDate(to: "02/01/97 15:20")

        // Assert
        XCTAssertEqual(timeCard.breaks.count, 1)
        XCTAssertEqual(timeCard.breaks[0].startDate, mockDateProvider.dateFormatter.date(from: "02/01/97 15:15"))
        XCTAssertEqual(timeCard.state, .onABreak)
    }

    func test_startBreak_whenStateIsOnABreak_throwsErrorAlreadyOnABreak() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        // Assert
        XCTAssertThrowsError(try timeCard.startBreak()) { error in
            XCTAssertEqual(error as? TimeCardError, .alreadyOnABreak)
        }
    }

    func test_startBreak_whenStateIsFinished_throwsErrorAlreadyFinished() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        // Assert
        XCTAssertThrowsError(try timeCard.startBreak()) { error in
            XCTAssertEqual(error as? TimeCardError, .alreadyFinished)
        }
    }

    // MARK: currentBreak

    func test_currentBreak_withoutBreaks_returnsNil() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        let currentBreak = try timeCard.currentBreak()

        // Assert
        XCTAssertEqual(currentBreak, nil)
    }

    func test_currentBreak_withCorrectBreaks_returnsTheUnfinishedOne() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()

        // Act
        let currentBreak = try timeCard.currentBreak()

        // Assert
        XCTAssertEqual(currentBreak, timeCard.breaks[0])
    }

    func test_currentBreak_withMultipleUnfinishedBreaks_throwsErrorMultipleUnfinishedBreaks() throws {
        // Arrange
        // first break: 15:15 - ongoing
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - ongoing
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Act
        // Assert
        XCTAssertThrowsError(try timeCard.currentBreak()) { error in
            XCTAssertEqual(error as? TimeCardError, .multipleUnfinishedBreaks)
        }
    }

    // MARK: finishBreak

    func test_finishBreak_whenStateIsOnABreak_updatesBreakEndDateAndUpdatesStateToOngoing() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        try timeCard.finishBreak()
        try mockDateProvider.updateDate(to: "02/01/97 15:25")

        // Assert
        XCTAssertEqual(timeCard.breaks.count, 1)
        XCTAssertEqual(timeCard.breaks[0].endDate, mockDateProvider.dateFormatter.date(from: "02/01/97 15:20"))
        XCTAssertEqual(timeCard.state, .ongoing)
    }

    func test_finishBreak_whenStateIsOngoing_throwsErrorNotOnABreak() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        // Assert
        XCTAssertThrowsError(try timeCard.finishBreak()) { error in
            XCTAssertEqual(error as? TimeCardError, .notOnABreak)
        }
    }

    func test_finishBreak_whenStateIsFinished_throwsErrorNotOnABreak() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        // Assert
        XCTAssertThrowsError(try timeCard.finishBreak()) { error in
            XCTAssertEqual(error as? TimeCardError, .notOnABreak)
        }
    }

    // MARK: finish

    func test_finish_whenStateIsOngoing_updatesEndDateAndStateToFinished() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()
        try mockDateProvider.updateDate(to: "02/01/97 15:20")

        // Assert
        XCTAssertEqual(timeCard.endDate, mockDateProvider.dateFormatter.date(from: "02/01/97 15:15"))
        XCTAssertEqual(timeCard.state, .finished)
    }

    func test_finish_whenStateIsOnABreak_throwsErrorOnABreak() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        // Assert
        XCTAssertThrowsError(try timeCard.finish()) { error in
            XCTAssertEqual(error as? TimeCardError, .onABreak)
        }
    }

    func test_finish_whenStateIsFinished_throwsErrorAlreadyFinished() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        // Assert
        XCTAssertThrowsError(try timeCard.finish()) { error in
            XCTAssertEqual(error as? TimeCardError, .alreadyFinished)
        }
    }

    // MARK: - isCompletelyEqual

    func test_isCompletelyEqual_whenIsEqual_returnsTrue() {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        // finish time: 16:00
        let endDate = mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds)

        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: endDate,
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(id: timeCard.id,
                                 start: timeCard.startDate,
                                 end: timeCard.endDate,
                                 breaks: timeCard.breaks,
                                 currentDateProvider: mockDateProvider)

        // Act
        let result = timeCard.isCompletelyEqual(to: timeCard2)

        // Assert
        XCTAssertTrue(result)
    }

    func test_isCompletelyEqual_whenIDIsDifferent_returnsFalse() {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        // finish time: 16:00
        let endDate = mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds)

        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: endDate,
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(start: timeCard.startDate,
                                 end: timeCard.endDate,
                                 breaks: timeCard.breaks,
                                 currentDateProvider: mockDateProvider)

        // Act
        let result = timeCard.isCompletelyEqual(to: timeCard2)

        // Assert
        XCTAssertFalse(result)
    }

    func test_isCompletelyEqual_whenStartDateIsDifferent_returnsFalse() {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        // finish time: 16:00
        let endDate = mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds)

        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: endDate,
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(id: timeCard.id,
                                 start: mockDateProvider.currentDate().addingTimeInterval(5),
                                 end: timeCard.endDate,
                                 breaks: timeCard.breaks,
                                 currentDateProvider: mockDateProvider)

        // Act
        let result = timeCard.isCompletelyEqual(to: timeCard2)

        // Assert
        XCTAssertFalse(result)
    }

    func test_isCompletelyEqual_whenEndDateIsDifferent_returnsFalse() {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        // finish time: 16:00
        let endDate = mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds)

        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: endDate,
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(id: timeCard.id,
                                 start: timeCard.startDate,
                                 end: mockDateProvider.currentDate(),
                                 breaks: timeCard.breaks,
                                 currentDateProvider: mockDateProvider)

        // Act
        let result = timeCard.isCompletelyEqual(to: timeCard2)

        // Assert
        XCTAssertFalse(result)
    }

    func test_isCompletelyEqual_whenBreaksIsDifferent_returnsFalse() {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        // finish time: 16:00
        let endDate = mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds)

        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: endDate,
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(id: timeCard.id,
                                 start: timeCard.startDate,
                                 end: timeCard.endDate,
                                 breaks: [],
                                 currentDateProvider: mockDateProvider)

        // Act
        let result = timeCard.isCompletelyEqual(to: timeCard2)

        // Assert
        XCTAssertFalse(result)
    }

    func test_isCompletelyEqual_whenStateIsDifferent_returnsFalse() throws {
        // Arrange
        // first break: 15:15 - 15:20
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds),
                              end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - 15:45
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))

        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                end: nil,
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(id: timeCard.id,
                                 start: timeCard.startDate,
                                 end: nil,
                                 breaks: timeCard.breaks,
                                 currentDateProvider: mockDateProvider)
        try timeCard2.finishBreak()

        // Act
        let result = timeCard.isCompletelyEqual(to: timeCard2)

        // Assert
        XCTAssertFalse(result)
    }

    // MARK: - Helpers

    func newBreak(start startDate: Date, end endDate: Date? = nil) -> Break {
        return Break(start: startDate,
                     end: endDate,
                     currentDateProvider: mockDateProvider)
    }

}
