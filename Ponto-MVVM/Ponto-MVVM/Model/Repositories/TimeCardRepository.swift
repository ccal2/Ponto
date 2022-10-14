//
//  TimeCardRepository.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import Foundation

protocol TimeCardRepository {
    func get(for: Date, completionHandler: TimeCardRepositoryGetCompletionHandler)
    func list(completionHandler: TimeCardRepositoryListCompletionHandler)
    func listFinished(limitedBy: Int?, completionHandler: TimeCardRepositoryListCompletionHandler)
    func save(_: TimeCard, sender: AnyObject?, completionHandler: TimeCardRepositorySaveCompletionHandler?)
    func remove(_: TimeCard, sender: AnyObject?, completionHandler: TimeCardRepositoryRemoveCompletionHandler?)
    func addListener(_: TimeCardRepositoryListener, with: Set<TimeCardRepositoryListenerType>)
    func removeListener(_: TimeCardRepositoryListener)
}

extension TimeCardRepository {

    func timeCard(_ timeCard: TimeCard, isWantedBy listenerTypes: Set<TimeCardRepositoryListenerType>) -> Bool {
        guard listenerTypes.isDisjoint(with: [.all, .timeCard(id: timeCard.id)]) else {
            return true
        }

        let listenerDates: [Date] = listenerTypes.compactMap { type in
            guard case let .fromDate(date) = type else {
                return nil
            }

            return date
        }

        return listenerDates.contains { listenerDate in
            timeCard.startDate > listenerDate
        }
    }

}

typealias TimeCardRepositoryGetCompletionHandler = (Result<TimeCard, TimeCardRepositoryError>) -> Void
typealias TimeCardRepositoryListCompletionHandler = (Result<[TimeCard], TimeCardRepositoryError>) -> Void
typealias TimeCardRepositorySaveCompletionHandler = (Result<Void, TimeCardRepositoryError>) -> Void
typealias TimeCardRepositoryRemoveCompletionHandler = (Result<Void, TimeCardRepositoryError>) -> Void

enum TimeCardRepositoryError: LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound:
            return NSLocalizedString("Time card not found", comment: "Error description")
        }
    }

}

protocol TimeCardRepositoryListener: AnyObject {
    var id: UUID { get }

    func timeCardRepositoryDidSave(_: TimeCard)
    func timeCardRepositoryDidRemove(_: TimeCard)
}

enum TimeCardRepositoryListenerType: Hashable {
    case timeCard(id: UUID)
    case fromDate(Date)
    case all
}
