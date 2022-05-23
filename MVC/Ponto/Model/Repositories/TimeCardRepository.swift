//
//  TimeCardRepository.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

import Foundation

protocol TimeCardRepository {
    func get(for: Date, completionHandler: TimeCardRepositoryGetCompletionHandler)
    func list(completionHandler: TimeCardRepositoryListCompletionHandler)
    func save(_: TimeCard, completionHandler: TimeCardRepositorySaveCompletionHandler)
}

typealias TimeCardRepositoryGetCompletionHandler = (Result<TimeCard, TimeCardRepositoryError>) -> Void
typealias TimeCardRepositoryListCompletionHandler = (Result<[TimeCard], TimeCardRepositoryError>) -> Void
typealias TimeCardRepositorySaveCompletionHandler = (Result<Void, TimeCardRepositoryError>) -> Void

enum TimeCardRepositoryError: LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound:
            return NSLocalizedString("Time card not found", comment: "Error description")
        }
    }

}

