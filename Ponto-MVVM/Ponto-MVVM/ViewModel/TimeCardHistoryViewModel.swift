//
//  TimeCardHistoryViewModel.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 29/08/22.
//

import Foundation

class TimeCardHistoryViewModel: TimeCardHistoryViewModelType {

    // MARK: - Properties

    override var title: String {
        Constants.TimeCardHistory.screenTitle
    }

    var timeCardsGroupedByMonth: [DateComponents: [TimeCard]] = [:]

    /// Injected dependencies
    private let timeCardRepository: TimeCardRepository

    // MARK: - Initializers

    init(timeCardRepository: TimeCardRepository = LocalTimeCardRepository.shared) {
        self.timeCardRepository = timeCardRepository
    }

    // MARK: - Methods

    override func fetchTimeCards() {
        timeCardRepository.listFinished(limitedBy: nil) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(timeCards):
                self.timeCardsGroupedByMonth = Dictionary(grouping: timeCards) { timeCard in
                    timeCard.startDate.monthComponents
                }

                self.timeCardListDatasGroupedByMonth = self.timeCardsGroupedByMonth.mapValues { timeCards in
                    timeCards.map { timeCard in
                        TimeCardListData(timeCard: timeCard)
                    }
                }.sorted { lhs, rhs in
                    guard let lhsYear = lhs.key.year,
                          let lhsMonth = lhs.key.month,
                          let rhsYear = rhs.key.year,
                          let rhsMonth = rhs.key.month else {
                        assertionFailure("The keys for `timeCardsGroupedByMonth` must all have year and month components")
                        return false
                    }

                    if lhsYear > rhsYear {
                        return true
                    } else if lhsYear < rhsYear {
                        return false
                    } else {
                        return lhsMonth > rhsMonth
                    }
                }.map { element in
                    let sectionTitle: String
                    if let monthDate = element.key.date {
                        sectionTitle = CommonFormatters.shared.monthDateFormatter.string(from: monthDate)
                    } else {
                        assertionFailure("Failed to get date from components")
                        sectionTitle = ""
                    }

                    return (key: sectionTitle, value: element.value)
                }
            case let .failure(error):
                print("Error when trying to load time cards: \(error.localizedDescription)")
            }
        }
    }

    override func timeCardDetailViewModel(for timeCardListData: TimeCardListData) -> TimeCardDetailViewModel? {
        timeCardsGroupedByMonth.values.flatMap { element in
            element
        }.first { timeCard in
            timeCard.id == timeCardListData.id
        }.map { timeCard in
            TimeCardDetailViewModel(timeCard: timeCard)
        }
    }

}
