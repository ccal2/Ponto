//
//  TimeCard.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 03/20/22.
//

import Foundation

protocol TimeCardDelegate: AnyObject {
    func timeCard(_: TimeCard, didUpdateState: TimeCard.State)
}

class TimeCard {

    // MARK: - Properties

    weak var delegate: TimeCardDelegate?

    private let id: UUID

    private(set) var startDate: Date
    private(set) var endDate: Date? = nil {
        didSet {
            // It's not possible to modify the endDate while on a break
            state = (endDate == nil) ? .ongoing : .finished
        }
    }
    private(set) var breaks: [Break] = []

    private(set) var state: State {
        didSet {
            delegate?.timeCard(self, didUpdateState: state)
        }
    }

    private var currentDateProvider: CurrentDateProvider

    var duration: TimeInterval {
        let referenceDate = endDate ?? currentDateProvider.currentDate()
        let breakTime = breaks.map({ $0.duration }).reduce(0, +)

        return referenceDate.timeIntervalSince(startDate) - breakTime
    }

    // MARK: - Initializer

    init(start: Date, currentDateProvider: CurrentDateProvider = DateProvider.sharedInstance) {
        self.id = UUID()
        self.startDate = start
        self.currentDateProvider = currentDateProvider
        self.state = .ongoing
    }

    // MARK: - Internal Methods

    func startBreak() throws {
        switch state {
        case .ongoing:
            let newBreak = Break(start: currentDateProvider.currentDate(),
                                 currentDateProvider: currentDateProvider)
            breaks.append(newBreak)
            state = .onABreak
        case .onABreak:
            throw TimeCardError.alreadyOnABreak
        case .finished:
            throw TimeCardError.alreadyFinished
        }
    }

    func currentBreak() throws -> Break? {
        let openBreaks = breaks.filter { aBreak in aBreak.endDate == nil }

        guard openBreaks.count <= 1 else {
            throw TimeCardError.multipleUnfinishedBreaks
        }

        return openBreaks.last
    }

    func finishBreak() throws {
        guard let currentBreak = try currentBreak() else {
            assert(state != .onABreak)
            throw TimeCardError.notOnABreak
        }
        assert(state == .onABreak)

        try currentBreak.finish()
        state = .ongoing
    }

    func finish() throws {
        switch state {
        case .ongoing:
            endDate = currentDateProvider.currentDate()
        case .onABreak:
            throw TimeCardError.onABreak
        case .finished:
            assert(endDate != nil)
            throw TimeCardError.alreadyFinished
        }
    }

}

// MARK: - Equatable

extension TimeCard: Equatable {

    static func == (lhs: TimeCard, rhs: TimeCard) -> Bool {
        lhs.id == rhs.id
    }

}

// MARK: - State

extension TimeCard {

    enum State {
        // Cases
        case ongoing
        case onABreak
        case finished
    }

}

// MARK: - Errors

enum TimeCardError: LocalizedError {
    // Cases
    case alreadyFinished
    case alreadyOnABreak
    case multipleUnfinishedBreaks
    case notOnABreak
    case onABreak

    // Description
    var errorDescription: String? {
        switch self {
        case .alreadyFinished:
            return NSLocalizedString("The time card has already finished", comment: "Error description")
        case .alreadyOnABreak:
            return NSLocalizedString("The time card is already on a break", comment: "Error description")
        case .multipleUnfinishedBreaks:
            return NSLocalizedString("The time card has multiple unfinished breaks", comment: "Error description")
        case .notOnABreak:
            return NSLocalizedString("The time card is not currently on a break", comment: "Error description")
        case .onABreak:
            return NSLocalizedString("The time card is currently on a break", comment: "Error description")
        }
    }

}
