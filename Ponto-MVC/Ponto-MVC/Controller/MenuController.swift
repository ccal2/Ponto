//
//  MenuController.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 04/10/22.
//

import UIKit

extension UIMenu.Identifier {
    static var timeCardMenu: UIMenu.Identifier { UIMenu.Identifier("com.CarolinaL.Ponto.menus.timeCardMenu") }
}

class MenuController {

    // MARK: - Properties

    let id: UUID = UUID()

    /// Model
    private var timeCard: TimeCard? {
        didSet {
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

    init(builder: UIMenuBuilder, timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared, currentDateProvider: CurrentDateProvider = DateProvider.shared) {
        self.timeCardRepository = timeCardRepository
        self.currentDateProvider = currentDateProvider

        builder.insertSibling(timeCardMenu(), afterMenu: .view)

        fetchTimeCard()
    }

    // MARK: - Methods

    // MARK: Menu creations

    func timeCardMenu() -> UIMenu {
        let clockInCommand = UIKeyCommand(title: Constants.Menu.clockIn,
                                          image: nil,
                                          action: #selector(AppDelegate.clockIn),
                                          input: "I",
                                          modifierFlags: [.alternate])

        let startBreakCommand = UIKeyCommand(title: Constants.Menu.startBreak,
                                             image: nil,
                                             action: #selector(AppDelegate.startBreak),
                                             input: "B",
                                             modifierFlags: [.alternate])

        let resumeCommand = UIKeyCommand(title: Constants.Menu.resume,
                                         image: nil,
                                         action: #selector(AppDelegate.resume),
                                         input: "R",
                                         modifierFlags: [.alternate])

        let clockOutCommand = UIKeyCommand(title: Constants.Menu.clockOut,
                                           image: nil,
                                           action: #selector(AppDelegate.clockOut),
                                           input: "O",
                                           modifierFlags: [.alternate])

        return UIMenu(title: Constants.Menu.timeCard,
                      image: nil,
                      identifier: .timeCardMenu,
                      options: [],
                      children: [clockInCommand, startBreakCommand, resumeCommand, clockOutCommand])
    }

    // MARK: Command actions

    @objc
    func clockIn() {
        assert(timeCard == nil)
        timeCard = TimeCard(start: currentDateProvider.currentDate())
    }

    @objc
    func startBreak() {
        assert(timeCard?.state == .ongoing)
        do {
            try timeCard?.startBreak()
        } catch {
            print("Error when trying to start a break on the current time card: \(error.localizedDescription)")
        }
    }

    @objc
    func resume() {
        assert(timeCard?.state == .onABreak)
        do {
            try timeCard?.finishBreak()
        } catch {
            print("Error when trying to finish the current break on the current time card: \(error.localizedDescription)")
        }
    }

    @objc
    func clockOut() {
        assert(timeCard?.state == .ongoing)
        do {
            try timeCard?.finish()
        } catch {
            print("Error when trying to finish the current time card: \(error.localizedDescription)")
        }
    }

    // MARK: Command state validation

    func validate(_ command: UICommand) {
        switch command.action {
        case #selector(AppDelegate.clockIn):
            command.attributes = timeCard?.state == nil ? [] : .disabled
        case #selector(AppDelegate.startBreak):
            command.attributes = timeCard?.state == .ongoing ? [] : .disabled
        case #selector(AppDelegate.resume):
            command.attributes = timeCard?.state == .onABreak ? [] : .disabled
        case #selector(AppDelegate.clockOut):
            command.attributes = timeCard?.state == .ongoing ? [] : .disabled
        default:
            break
        }
    }

    // MARK: Helpers

    func fetchTimeCard() {
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

}

// MARK: - TimeCardRepositoryListener

extension MenuController: TimeCardRepositoryListener {

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
