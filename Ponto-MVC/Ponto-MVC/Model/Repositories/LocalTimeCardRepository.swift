//
//  LocalTimeCardRepository.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import Foundation

class LocalTimeCardRepository: TimeCardRepository {

    static let shared = LocalTimeCardRepository()

    private var timeCards: Set<TimeCard>
    private(set) var listenersAndTypes: [(listener: TimeCardRepositoryListener, types: Set<TimeCardRepositoryListenerType>)] = []

    init(timeCards: Set<TimeCard> = []) {
        self.timeCards = timeCards
    }

    func get(for date: Date, completionHandler: TimeCardRepositoryGetCompletionHandler) {
        let filteredTimeCards = timeCards.filter { timeCard in
            guard let timeCardYear = timeCard.startDate.dayComponents.year,
                  let timeCardMonth = timeCard.startDate.dayComponents.month,
                  let timeCardDay = timeCard.startDate.dayComponents.day,
                  let dateYear = date.dayComponents.year,
                  let dateMonth = date.dayComponents.month,
                  let dateDay = date.dayComponents.day else {
                return false
            }

            if timeCardYear == dateYear {
                if timeCardMonth == dateMonth {
                    return timeCardDay <= dateDay
                } else {
                    return timeCardMonth < dateMonth
                }
            } else {
                return timeCardYear < dateYear
            }
        }

        let sortedTimeCards = filteredTimeCards.sorted { (lhs, rhs) in
            lhs.startDate < rhs.startDate
        }

        guard let lastTimeCard = sortedTimeCards.last else {
            completionHandler(.failure(.notFound))
            return
        }

        if lastTimeCard.state != .finished {
            completionHandler(.success(lastTimeCard))
        } else if lastTimeCard.startDate.dayComponents == date.dayComponents {
            completionHandler(.success(lastTimeCard))
        } else {
            completionHandler(.failure(.notFound))
        }
    }

    func list(completionHandler: TimeCardRepositoryListCompletionHandler) {
        let sortedTimeCards = timeCards.sorted { (lhs, rhs) in
            lhs.startDate > rhs.startDate
        }

        completionHandler(.success(sortedTimeCards))
    }

    func listFinished(limitedBy countLimit: Int?, completionHandler: TimeCardRepositoryListCompletionHandler) {
        let finishedTimeCards = timeCards.filter { timeCard in
            timeCard.state == .finished
        }

        var sortedTimeCards = finishedTimeCards.sorted { lhs, rhs in
            lhs.startDate > rhs.startDate
        }

        if let limit = countLimit, limit < sortedTimeCards.count {
            sortedTimeCards = sortedTimeCards.dropLast(sortedTimeCards.count - limit)
        }

        completionHandler(.success(sortedTimeCards))
    }

    func save(_ timeCard: TimeCard, sender: AnyObject?, completionHandler: TimeCardRepositorySaveCompletionHandler?) {
        timeCards.update(with: timeCard)
        completionHandler?(.success(()))

        for (listener, types) in listenersAndTypes where self.timeCard(timeCard, isWantedBy: types) && sender !== listener {
            listener.timeCardRepositoryDidSave(timeCard)
        }
    }

    func remove(_ timeCard: TimeCard, sender: AnyObject?, completionHandler: TimeCardRepositoryRemoveCompletionHandler?) {
        guard timeCards.remove(timeCard) != nil else {
            completionHandler?(.failure(.notFound))
            return
        }
        completionHandler?(.success(()))

        for (listener, types) in listenersAndTypes where self.timeCard(timeCard, isWantedBy: types) && sender !== listener {
            listener.timeCardRepositoryDidRemove(timeCard)
        }
    }

    func addListener(_ listener: TimeCardRepositoryListener, with types: Set<TimeCardRepositoryListenerType>) {
        assert(!types.isEmpty)

        if let index = listenersAndTypes.firstIndex(where: { (element, _) in element.id == listener.id }) {
            listenersAndTypes[index].types = types
        } else {
            listenersAndTypes.append((listener, types))
        }
    }

    func removeListener(_ listener: TimeCardRepositoryListener) {
        listenersAndTypes.removeAll { (element, _) in
            element.id == listener.id
        }
    }

}
