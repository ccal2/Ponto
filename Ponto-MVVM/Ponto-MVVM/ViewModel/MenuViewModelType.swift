//
//  MenuViewModelType.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 29/09/22.
//

import Combine

class MenuViewModelType: ObservableObject {

    // MARK: - Properties

    var isClockInDisabled: Bool = true
    var isStartBreakDisabled: Bool = true
    var isResumeDisabled: Bool = true
    var isClockOutDisabled: Bool = true

    // MARK: - Methods

    func fetchTimeCard() { }
    func clockIn() { }
    func startBreak() { }
    func resume() { }
    func clockOut() { }

}
