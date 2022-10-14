//
//  MockTimeCardRepositoryListener.swift
//  Ponto-MVCTests
//
//  Created by Carolina Cruz Agra Lopes on 29/09/22.
//

import Foundation
@testable import Ponto_MVC

class MockTimeCardRepositoryListener: TimeCardRepositoryListener {

    let id: UUID = UUID()

    var savedTimeCard: TimeCard?
    var removedTimeCard: TimeCard?

    func timeCardRepositoryDidSave(_ timeCard: TimeCard) {
        savedTimeCard = timeCard
    }

    func timeCardRepositoryDidRemove(_ timeCard: TimeCard) {
        removedTimeCard = timeCard
    }

}
