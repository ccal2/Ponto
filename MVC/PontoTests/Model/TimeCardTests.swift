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

    func test_initialState() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act

        // Assert
        XCTAssertEqual(timeCard.state, .ongoing)
        XCTAssertEqual(timeCard.breaks, [])
        XCTAssertNil(timeCard.endDate)
    }

    // MARK: duration

    func test_duration_whenStateIsOngoing_withoutBreaks() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:15")

        // Assert
        XCTAssertEqual(timeCard.duration, 15 * Constants.minutesToSeconds)
    }

    func test_duration_whenStateIsOngoing_withBreaks() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        // first break: 15:15 - 15:20
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        try timeCard.finishBreak()
        // second break: 15:35 - 15:45
        try mockDateProvider.updateDate(to: "02/01/97 15:35")
        try timeCard.startBreak()
        try mockDateProvider.updateDate(to: "02/01/97 15:45")
        try timeCard.finishBreak()

        // Act
        // start - current date: 15:00 - 16:00
        try mockDateProvider.updateDate(to: "02/01/97 16:00")

        // Assert
        XCTAssertEqual(timeCard.duration, 45 * Constants.minutesToSeconds)
    }

    func test_duration_whenStateIsFinished_withoutBreaks() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 15:20")

        // Assert
        XCTAssertEqual(timeCard.duration, 15 * Constants.minutesToSeconds)
    }

    func test_duration_whenStateIsFinished_withBreaks() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        // first break: 15:15 - 15:20
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        try timeCard.finishBreak()
        // second break: 15:35 - 15:45
        try mockDateProvider.updateDate(to: "02/01/97 15:35")
        try timeCard.startBreak()
        try mockDateProvider.updateDate(to: "02/01/97 15:45")
        try timeCard.finishBreak()
        // finish time: 16:00
        try mockDateProvider.updateDate(to: "02/01/97 16:00")
        try timeCard.finish()

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 16:20")

        // Assert
        XCTAssertEqual(timeCard.duration, 45 * Constants.minutesToSeconds)
    }

    func test_duration_whenStateIsOnABreak() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        // first break: 15:15 - 15:20
        try mockDateProvider.updateDate(to: "02/01/97 15:15")
        try timeCard.startBreak()
        try mockDateProvider.updateDate(to: "02/01/97 15:20")
        try timeCard.finishBreak()
        // second break: 15:35 - ongoing
        try mockDateProvider.updateDate(to: "02/01/97 15:35")
        try timeCard.startBreak()

        // Act
        // start - current date: 15:00 - 15:40
        try mockDateProvider.updateDate(to: "02/01/97 15:40")

        // Assert
        XCTAssertEqual(timeCard.duration, 30 * Constants.minutesToSeconds)
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

    // Commented out because this condition is not something we can do
    // Calling `startBreak` two times in a row like this actually throws an error, so we can't have multiple unfinished breaks
    //    func test_currentBreak_withMultipleUnfinishedBreaks_throwsError() throws {
    //        // Arrange
    //        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
    //                                currentDateProvider: mockDateProvider)
    //        try mockDateProvider.updateDate(to: "02/01/97 15:15")
    //        try timeCard.startBreak()
    //        try mockDateProvider.updateDate(to: "02/01/97 15:20")
    //        try timeCard.startBreak()
    //
    //        // Act
    //        do {
    //            let _ = try timeCard.currentBreak()
    //            XCTFail("Trying to get the current break when there are multiple unfinished breaks should fail with error `TimeCardError.multipleUnfinishedBreaks`")
    //        } catch TimeCardError.multipleUnfinishedBreaks {
    //            // Assert
    //            // OK - expected error
    //        } catch {
    //            XCTFail("Expected `TimeCardError.multipleUnfinishedBreaks` error, but got: \(error) (\(error.localizedDescription))")
    //        }
    //    }

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

}
