//
//  LocalTimeCardRepositoryTests.swift
//  Ponto-MVVMTests
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import XCTest

@testable import Ponto_MVVM

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
                XCTAssertEqual(error, .notFound, "Expected `TimeCardRepositoryError.notFound` error, but got: \(error) (\(error.localizedDescription))")
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
                XCTAssertEqual(error, .notFound, "Expected `TimeCardRepositoryError.notFound` error, but got: \(error) (\(error.localizedDescription))")
            }
            getExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    func test_get_whenThereIsATimeCardFromTheSameDay_resultsInSuccessWithCorrectTimeCard() throws {
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

    // MARK: list

    func test_list_whenTimeCardsIsEmpty_resultsInSuccessWithEmptyList() throws {
        // Arrange
        let repository = LocalTimeCardRepository()

        // Act
        let listExpectation = expectation(description: "Repository list completion")
        repository.list { result in
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

    func test_list_whenTimeCardsIsNotEmpty_resultsInSuccessWithCorrectList() throws {
        // Arrange
        // first timeCard: 02/01/97 15:00-15:20
        let timeCard1 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                                currentDateProvider: mockDateProvider)
        // second timeCard: 03/01/97 15:00-
        try mockDateProvider.updateDate(to: "03/01/97 15:00")
        let timeCard2 = TimeCard(start: mockDateProvider.currentDate(),
                                 currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard1, timeCard2])

        // Act
        let listExpectation = expectation(description: "Repository list completion")
        repository.list { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTAssertEqual(timeCards, [timeCard2, timeCard1])
            case let .failure(error):
                XCTFail("Failed to list timeCards: \(error.localizedDescription)")
            }
            listExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    // MARK: listFinished

    func test_listFinished_whenThereAreNoFinishedTimeCards_resultsInSuccessWithEmptyList() throws {
        // Arrange
        // first timeCard: 02/01/97 15:00-15:20
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                 currentDateProvider: mockDateProvider)
        // second timeCard: 03/01/97 15:00-
        try mockDateProvider.updateDate(to: "03/01/97 15:00")
        let repository =  LocalTimeCardRepository(timeCards: [timeCard])

        // Act
        let listExpectation = expectation(description: "Repository listFinished completion")
        repository.listFinished(limitedBy: nil) { result in
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

    func test_listFinishedLimitedBy_whenThereAreMoreFinishedTimeCardsThenLimit_resultsInSuccessWithLimitedList() throws {
        // Arrange
        // first timeCard: 02/01/97 15:00-15:20
        let timeCard1 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                                 currentDateProvider: mockDateProvider)
        // second timeCard: 03/01/97 15:00-
        try mockDateProvider.updateDate(to: "03/01/97 15:00")
        let timeCard2 = TimeCard(start: mockDateProvider.currentDate(),
                                 end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                                 currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard1, timeCard2])

        // Act
        let listExpectation = expectation(description: "Repository listFinished completion")
        repository.listFinished(limitedBy: 1) { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTAssertEqual(timeCards, [timeCard2])
            case let .failure(error):
                XCTFail("Failed to list timeCards: \(error.localizedDescription)")
            }
            listExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    // MARK: save

    func test_save_whenTimeCardIsNotInRepository_resultsInSuccess_addsTimeCardToList() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()

        // Act
        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        let listExpectation = expectation(description: "Repository listFinished completion")
        repository.list { result in
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

    func test_save_whenTimeCardIsAlreadyInRepository_resultsInSuccess_doesntDuplicateTimeCardAndUpdates() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let timeCard2 = TimeCard(id: timeCard.id,
                                 start: timeCard.startDate,
                                 end: mockDateProvider.currentDate().addingTimeInterval(20 * Constants.TimeConversion.minutesToSeconds),
                                 currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])

        // Act
        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard2, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        let listExpectation = expectation(description: "Repository list completion")
        repository.list { result in
            // Assert
            switch result {
            case let .success(timeCards):
                XCTAssertEqual(timeCards, [timeCard2])
                XCTAssertTrue(timeCards[0].isCompletelyEqual(to: timeCard2))
            case let .failure(error):
                XCTFail("Failed to list timeCards: \(error.localizedDescription)")
            }
            listExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    // MARK: save with listener

    func test_save_withListenerDifferentThanSenderWithTypeAll_sendsTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.all]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertEqual(listener.savedTimeCard, timeCard)
    }

    func test_save_withListenerEqualToSenderWithTypeAll_doesntSendTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.all]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard, sender: listener) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertNil(listener.savedTimeCard)
    }

    func test_save_withListenerWithTypeTimeCardWithSameID_sendsTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.timeCard(id: timeCard.id)]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertEqual(listener.savedTimeCard, timeCard)
    }

    func test_save_withListenerWithTypeTimeCardWithDifferentID_doesntSendTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.timeCard(id: UUID())]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard, sender: listener) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertNil(listener.savedTimeCard)
    }

    func test_save_withListenerWithTypeFromDateWithPreviousDate_sendsTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.fromDate(mockDateProvider.currentDate().addingTimeInterval(-10))]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertEqual(listener.savedTimeCard, timeCard)
    }

    func test_save_withListenerWithTypeFromDateWithLaterDate_doesntSendTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.fromDate(mockDateProvider.currentDate().addingTimeInterval(10))]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let saveExpectation = expectation(description: "Repository save completion")
        repository.save(timeCard, sender: listener) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to save timeCard: \(error.localizedDescription)")
            }
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertNil(listener.savedTimeCard)
    }

    // MARK: remove

    func test_remove_whenTimeCardIsNotInRepository_resultsInNotFoundError() {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository()

        // Act
        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: repository) { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Trying to remove a time card that is not in the repository should fail with `TimeCardRepositoryError.notFound`, but it succeeded")
            case let .failure(error):
                XCTAssertEqual(error, .notFound, "Expected `TimeCardRepositoryError.notFound` error, but got: \(error) (\(error.localizedDescription))")
            }
            removeExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)
    }

    func test_remove_whenTimeCardIsInRepository_resultsInSuccess_removesTimeCardFromList() {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])

        // Act
        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to get timeCard: \(error.localizedDescription)")
            }
            removeExpectation.fulfill()
        }

        let listExpectation = expectation(description: "Repository list completion")
        repository.list { result in
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

    // MARK: remove with listener

    func test_remove_withListenerDifferentThanSenderWithTypeAll_sendsTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.all]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to remove timeCard: \(error.localizedDescription)")
            }
            removeExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertEqual(listener.removedTimeCard, timeCard)
    }

    func test_remove_withListenerEqualToSenderWithTypeAll_doesntSendTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.all]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: listener) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to remove timeCard: \(error.localizedDescription)")
            }
            removeExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertNil(listener.removedTimeCard)
    }

    func test_remove_withListenerWithTypeTimeCardWithSameID_sendsTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.timeCard(id: timeCard.id)]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to remove timeCard: \(error.localizedDescription)")
            }
            removeExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertEqual(listener.removedTimeCard, timeCard)
    }

    func test_remove_withListenerWithTypeTimeCardWithDifferentID_doesntSendTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.timeCard(id: UUID())]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: listener) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to remove timeCard: \(error.localizedDescription)")
            }
            removeExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertNil(listener.removedTimeCard)
    }

    func test_remove_withListenerWithTypeFromDateWithPreviousDate_sendsTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.fromDate(mockDateProvider.currentDate().addingTimeInterval(-10))]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: repository) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to remove timeCard: \(error.localizedDescription)")
            }
            removeExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertEqual(listener.removedTimeCard, timeCard)
    }

    func test_remove_withListenerWithTypeFromDateWithLaterDate_doesntSendTimeCardToListener() throws {
        // Arrange
        let timeCard = TimeCard(start: mockDateProvider.currentDate(),
                                currentDateProvider: mockDateProvider)
        let repository = LocalTimeCardRepository(timeCards: [timeCard])
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.fromDate(mockDateProvider.currentDate().addingTimeInterval(10))]

        // Act
        repository.addListener(listener, with: listenerTypes)

        let removeExpectation = expectation(description: "Repository remove completion")
        repository.remove(timeCard, sender: listener) { result in
            if case let .failure(error) = result {
                XCTFail("Failed to remove timeCard: \(error.localizedDescription)")
            }
            removeExpectation.fulfill()
        }

        waitForExpectations(timeout: expectationWaitingTimeout)

        // Assert
        XCTAssertNil(listener.removedTimeCard)
    }

    // MARK: - addListener

    func test_addListener_addsListenerToList() {
        // Arrange
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.all]

        // Act
        repository.addListener(listener, with: listenerTypes)

        // Assert
        let listContainsListenerAndTypes = repository.listenersAndTypes.contains { item in
            item.listener.id == listener.id && item.types == listenerTypes
        }
        XCTAssertTrue(listContainsListenerAndTypes)
    }

    func test_addListenerAlreadyInList_updatesListenerInList() {
        // Arrange
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.all]
        let listenerTypes2: Set<TimeCardRepositoryListenerType> = [.fromDate(Date())]

        // Act
        repository.addListener(listener, with: listenerTypes)
        repository.addListener(listener, with: listenerTypes2)

        // Assert
        let listContainsListenerAndTypes = repository.listenersAndTypes.contains { item in
            item.listener.id == listener.id && item.types == listenerTypes2
        }
        XCTAssertTrue(listContainsListenerAndTypes)
    }

    // MARK: - removeListener

    func test_removeListener_removesListenerFromList() {
        // Arrange
        let repository = LocalTimeCardRepository()
        let listener = MockTimeCardRepositoryListener()
        let listenerTypes: Set<TimeCardRepositoryListenerType> = [.all]

        // Act
        repository.addListener(listener, with: listenerTypes)
        repository.removeListener(listener)

        // Assert
        XCTAssertTrue(repository.listenersAndTypes.isEmpty)
    }

}
