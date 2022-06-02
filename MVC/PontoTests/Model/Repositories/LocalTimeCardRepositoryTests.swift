//
//  LocalTimeCardRepositoryTests.swift
//  Ponto-MVCTests
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import XCTest
@testable import Ponto_MVC

class LocalTimeCardRepositoryTests: XCTestCase {

    // MARK: - Properties

    var mockDateProvider: MockDateProvider!
    let expectationWaitingTimeout: TimeInterval = 0.5

    // MARK: - Set up & Tear down

    override func setUpWithError() throws {
        mockDateProvider = MockDateProvider()
        try mockDateProvider.updateDate(to: "02/01/97 15:00")
    }

    override func tearDownWithError() throws {
        mockDateProvider = nil
    }

    // MARK: - Tests

    // MARK: list

    func test_list_whenTimeCardsIsEmpty_resultsInSuccess() throws {
        // Arrange
        let repository = LocalTimeCardRepository()

        // Act
        let listExpectation = expectation(description: "Repository list completion")
        repository.list() { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTAssertTrue(timeCards.isEmpty)
            case let .failure(error):
                XCTFail("Failed to list timeCards: \(error.localizedDescription)")
            }
            listExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    func test_list_whenTimeCardsIsNotEmpty_resultsInSuccess() throws {
        // Arrange
        // first timeCard: 02/01/97 15:00-15:20
        let timeCard1 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                                currentDateProvider: mockDateProvider)
        // second timeCard: 03/01/97 15:00-16:00
        try mockDateProvider.updateDate(to: "03/01/97 15:00")
        let timeCard2 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds),
                                 currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard1, timeCard2])

        // Act
        let listExpectation = expectation(description: "Repository list completion")
        repository.list() { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTAssertEqual(timeCards, [timeCard1, timeCard2])
            case let .failure(error):
                XCTFail("Failed to list timeCards: \(error.localizedDescription)")
            }
            listExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    // MARK: save

    func test_save_resultsInSuccess() throws {
        // Arrange
        let repository = LocalTimeCardRepository()
        let timeCard = TimeCard(start: mockDateProvider.currentDate(), currentDateProvider: mockDateProvider)

        // Act
        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        let listExpectation = expectation(description: "Repository list completion")
        repository.list() { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTAssertTrue(timeCards.contains(timeCard))
            case let .failure(error):
                XCTFail("Failed to list timeCards: \(error.localizedDescription)")
            }
            listExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    func test_save_sameTimeCard_resultsInSuccess_doesntDuplicateTimeCard() throws {
        // Arrange
        let repository = LocalTimeCardRepository()
        let timeCard = TimeCard(start: mockDateProvider.currentDate(), currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(id: timeCard.id, start: mockDateProvider.currentDate(), currentDateProvider: mockDateProvider)

        // Act
        let saveExpectation1 = expectation(description: "Repository save completion 1")
        repository.save(timeCard) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation1.fulfill()
        }
        try timeCard2.finish()
        let saveExpectation2 = expectation(description: "Repository save completion 1")
        repository.save(timeCard2) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation2.fulfill()
        }

        let listExpectation = expectation(description: "Repository list completion")
        repository.list() { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTAssertEqual(timeCards, [timeCard])
            case let .failure(error):
                XCTFail("Failed to list timeCards: \(error.localizedDescription)")
            }
            listExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    // MARK: get

    func test_get_whenTimeCardsIsEmpty_resultsInNotFoundError() throws {
        // Arrange
        let repository = LocalTimeCardRepository()

        // Act
        let getExpectation = expectation(description: "Repository get completion")
        repository.get(for: mockDateProvider.currentDate()) { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTFail("Trying to get a time card when there are none should fail with `TimeCardRepositoryError.notFound`, but it succeeded with timeCards: \(timeCards)")
            case let .failure(error):
                if error != .notFound {
                    XCTFail("Expected `TimeCardRepositoryError.notFound` error, but got: \(error) (\(error.localizedDescription))")
                }
                // OK - expected error
            }
            getExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    func test_get_whenThereAreOnlyTimeCardsAfterTheDay_resultsInNotFoundError() throws {
        // Arrange
        // first timeCard: 02/01/97 15:00-15:20
        let timeCard1 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                                 currentDateProvider: mockDateProvider)
        // second timeCard: 03/01/97 15:00-16:00
        try mockDateProvider.updateDate(to: "03/01/97 15:00")
        let timeCard2 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds),
                                 currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard1, timeCard2])

        // Act
        try mockDateProvider.updateDate(to: "01/01/97 15:00")
        let getExpectation = expectation(description: "Repository get completion")
        repository.get(for: mockDateProvider.currentDate()) { result in
            // Assert
            switch result {
            case let .success(timeCard):
                XCTFail("Trying to get a time card when there are none should fail with `TimeCardRepositoryError.notFound`, but it succeeded with timeCard: \(timeCard)")
            case let .failure(error):
                if error != .notFound {
                    XCTFail("Expected `TimeCardRepositoryError.notFound` error, but got: \(error) (\(error.localizedDescription))")
                }
                // OK - expected error
                getExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    func test_get_whenThereIsATimeCardFromTheSameDay_resultsInSuccess() throws {
        // Arrange
        // first timeCard: 02/01/97 15:00-15:20
        let timeCard1 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                                 currentDateProvider: mockDateProvider)
        // second timeCard: 03/01/97 15:00-16:00
        try mockDateProvider.updateDate(to: "03/01/97 15:00")
        let timeCard2 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(1 * Constants.TimeConversion.hoursToSeconds),
                                 currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard1, timeCard2])

        // Act
        try mockDateProvider.updateDate(to: "02/01/97 14:00")
        let getExpectation = expectation(description: "Repository get completion")
        repository.get(for: mockDateProvider.currentDate()) { result in
            // Assert
            switch result {
            case let .success(timeCard):
                XCTAssertEqual(timeCard, timeCard1)
            case let .failure(error):
                XCTFail("Failed to get timeCard: \(error.localizedDescription)")
            }
            getExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

}
