//
//  TimeCardViewModelType.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 25/07/22.
//

import Combine

class TimeCardViewModelType: ObservableObject {

    // MARK: - Properties

    var title: String { fatalError("subclass should override") }
    var isTitleLarge: Bool { fatalError("subclass should override") }
    @Published var durationText: String = Constants.TimeCardDetails.durationPlaceholder
    @Published var breakText: String? = nil
    var pauseResumeButtonImageName: String? { fatalError("subclass should override") }
    var startStopButtonImageName: String? { fatalError("subclass should override") }
    var isPauseResumeButtonDisabled: Bool { fatalError("subclass should override") }
    var isStartStopButtonDisabled: Bool { fatalError("subclass should override") }
    var clockInText: String { fatalError("subclass should override") }
    var clockOutText: String { fatalError("subclass should override") }
    var breakList: [BreakListData] { fatalError("subclass should override") }

    // MARK: - Methods

    func fetchTimeCard() { fatalError("subclass should override") }
    func pauseOrResumeTimeCard() { fatalError("subclass should override") }
    func startOrStopTimeCard() { fatalError("subclass should override") }

}

// MARK: - BreakListData

struct BreakListData: Hashable {

    // MARK: - Properties

    var startText: String
    var finishText: String
    var durationText: String

    // MARK: - Initializers

    init(startText: String, finishText: String, durationText: String) {
        self.startText = startText
        self.finishText = finishText
        self.durationText = durationText
    }

    init(`break`: Break) {
        startText = CommonFormatters.shared.timeDateFormatter.string(from: `break`.startDate)

        if let endDate = `break`.endDate {
            finishText = CommonFormatters.shared.timeDateFormatter.string(from: endDate)
        } else {
            finishText = Constants.TimeCardDetails.timePlaceholder
        }

        if `break`.endDate != nil, let formattedText = CommonFormatters.shared.durationDateComponentsFormatter.string(from: `break`.duration) {
            durationText = formattedText
        } else {
            durationText = Constants.TimeCardDetails.ongoingBreakIndicator
        }
    }

}
