//
//  MenuViewModel.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 28/09/22.
//

import Combine
import Foundation

class MenuViewModel: MenuViewModelType {

    // MARK: - Properties

    let id: UUID = UUID()

    /// Model
    @Published private var timeCard: TimeCard? {
        didSet {
            updateDisabledStates()
            guard let timeCard = timeCard else {
                return
            }
            if !(oldValue?.isCompletelyEqual(to: timeCard) ?? false) {
                timeCardRepository.save(timeCard, sender: self, completionHandler: nil)
                dateForTimeCardListener = timeCard.startDate
            }
        }
    }

    private var dateForTimeCardListener: Date?

    /// Injected dependencies
    private let timeCardRepository: TimeCardRepository
    private var currentDateProvider: CurrentDateProvider

    // MARK: - Initializers

    init(timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared, currentDateProvider: CurrentDateProvider = DateProvider.shared) {
        self.timeCardRepository = timeCardRepository
        self.currentDateProvider = currentDateProvider
        super.init()
        updateDisabledStates()
    }

    // MARK: - Methods

    override func fetchTimeCard() {
        timeCardRepository.get(for: currentDateProvider.currentDate()) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(timeCard):
                self.timeCard = timeCard
                self.timeCardRepository.addListener(self, with: [.timeCard(id: timeCard.id)])
            case let .failure(error):
                print("Error when trying to load the current time card: \(error.localizedDescription)")
                let currentDate = self.currentDateProvider.currentDate()
                self.dateForTimeCardListener = currentDate
                self.timeCardRepository.addListener(self, with: [.fromDate(currentDate)])
            }
        }
    }

    override func clockIn() {
        assert(timeCard == nil)
        timeCard = TimeCard(start: currentDateProvider.currentDate())
    }

    override func startBreak() {
        assert(timeCard?.state == .ongoing)
        do {
            try timeCard?.startBreak()
        } catch {
            print("Error when trying to start a break on the current time card: \(error.localizedDescription)")
        }
    }

    override func resume() {
        assert(timeCard?.state == .onABreak)
        do {
            try timeCard?.finishBreak()
        } catch {
            print("Error when trying to finish the current break on the current time card: \(error.localizedDescription)")
        }
    }

    override func clockOut() {
        assert(timeCard?.state == .ongoing)
        do {
            try timeCard?.finish()
        } catch {
            print("Error when trying to finish the current time card: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func updateDisabledStates() {
        isClockInDisabled = timeCard?.state != nil
        isStartBreakDisabled = timeCard?.state != .ongoing
        isResumeDisabled = timeCard?.state != .onABreak
        isClockOutDisabled = timeCard?.state != .ongoing
    }

}

// MARK: - TimeCardRepositoryListener

extension MenuViewModel: TimeCardRepositoryListener {

    func timeCardRepositoryDidSave(_ savedTimeCard: TimeCard) {
        if let timeCard = timeCard, savedTimeCard == timeCard {
            guard !timeCard.isCompletelyEqual(to: savedTimeCard) else {
                return
            }
            self.timeCard = savedTimeCard
        } else if let referenceDate = dateForTimeCardListener, savedTimeCard.startDate > referenceDate {
            timeCard = savedTimeCard
        }
    }

    func timeCardRepositoryDidRemove(_ removedTimeCard: TimeCard) {
        guard removedTimeCard == timeCard else {
            return
        }

        timeCard = nil
    }

}
