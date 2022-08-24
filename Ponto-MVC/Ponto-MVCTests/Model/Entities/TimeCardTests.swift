//
//  TimeCardTests.swift
//  Ponto-MVCTests
//
//  Created by Carolina Cruz Agra Lopes on 03/21/22.
//

import XCTest

@testable import Ponto_MVC

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

    func test_startBreak_whenStateIsOngoing_addsNewBreakAndUpdatesState() throws {
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

    func test_startBreak_whenStateIsOnABreak_throwsError() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        do {
            try timeCard.startBreak()
            XCTFail("Trying to start a new break while another is ongoing should fail with error `TimeCardError.alreadyOnABreak`")
        } catch TimeCardError.alreadyOnABreak {
            // Assert
            // OK - expected error
        } catch {
            XCTFail("Expected `TimeCardError.alreadyOnABreak` error, but got: \(error) (\(error.localizedDescription))")
        }
    }

    func test_startBreak_whenStateIsFinished_throwsError() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        do {
            try timeCard.startBreak()
            XCTFail("Trying to start a new break when the time card has already finished should fail with error `TimeCardError.alreadyFinished`")
        } catch TimeCardError.alreadyFinished {
            // Assert
            // OK - expected error
        } catch {
            XCTFail("Expected `TimeCardError.alreadyFinished` error, but got: \(error) (\(error.localizedDescription))")
        }
    }

    // MARK: currentBreak

    func test_currentBreak_whithoutBreaks_returnsNil() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        let currentBreak = try timeCard.currentBreak()

        // Assert
        XCTAssertEqual(currentBreak, nil)
    }

    func test_currentBreak_withCorrectBreaks_returnsTheUnfineshedOne() throws {
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

    func test_currentBreak_withMultipleUnfinishedBreaks_throwsError() throws {
        // Arrange
        // first break: 15:15 - ongoing
        let break1 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(15 * Constants.TimeConversion.minutesToSeconds))
        // second break: 15:35 - ongoing
        let break2 = newBreak(start: mockDateProvider.currentDate().addingTimeInterval(35 * Constants.TimeConversion.minutesToSeconds))
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                breaks: [break1, break2],
                                currentDateProvider: mockDateProvider)

        // Act
        do {
            _ = try timeCard.currentBreak()
            XCTFail("Trying to get the current break when there are multiple unfinished breaks should fail with error `TimeCardError.multipleUnfinishedBreaks`")
        } catch TimeCardError.multipleUnfinishedBreaks {
            // Assert
            // OK - expected error
        } catch {
            XCTFail("Expected `TimeCardError.multipleUnfinishedBreaks` error, but got: \(error) (\(error.localizedDescription))")
        }
    }

    // MARK: finishBreak

    func test_finishBreak_whenStateIsOnABreak_updatesBreakAndUpdatesState() throws {
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

    func test_finishBreak_whenStateIsOngoing_throwsError() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        do {
            try timeCard.finishBreak()
            XCTFail("Trying to finish break when there's no ongoing break should fail with error `TimeCardError.notOnABreak`")
        } catch TimeCardError.notOnABreak {
            // Assert
            // OK - expected error
        } catch {
            XCTFail("Expected `TimeCardError.notOnABreak` error, but got: \(error) (\(error.localizedDescription))")
        }
    }

    func test_finishBreak_whenStateIsFinished_throwsError() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        do {
            try timeCard.finishBreak()
            XCTFail("Trying to finish break when there's no ongoing break should fail with error `TimeCardError.notOnABreak`")
        } catch TimeCardError.notOnABreak {
            // Assert
            // OK - expected error
        } catch {
            XCTFail("Expected `TimeCardError.notOnABreak` error, but got: \(error) (\(error.localizedDescription))")
        }
    }

    // MARK: finish

    func test_finish_whenStateIsOngoing_updatesEndDateAndState() throws {
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

    func test_finish_whenStateIsOnABreak_throwsError() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        do {
            try timeCard.finish()
            XCTFail("Trying to finish a time card that is currently on a break should fail with error `TimeCardError.onABreak`")
        } catch TimeCardError.onABreak {
            // Assert
            // OK - expected error
        } catch {
            XCTFail("Expected `TimeCardError.onABreak` error, but got: \(error) (\(error.localizedDescription))")
        }
    }

    func test_finish_whenStateIsFinished_throwsError() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        do {
            try timeCard.finish()
            XCTFail("Trying to finish a time card that has already been finished before should fail with error `TimeCardError.alreadyFinished`")
        } catch TimeCardError.alreadyFinished {
            // Assert
            // OK - expected error
        } catch {
            XCTFail("Expected `TimeCardError.alreadyFinished` error, but got: \(error) (\(error.localizedDescription))")
        }
    }

    // MARK: - Helpers

    func newBreak(start startDate: Date, end endDate: Date? = nil) -> Break {
        return Break(start: startDate,
                     end: endDate,
                     currentDateProvider: mockDateProvider)
    }

}
