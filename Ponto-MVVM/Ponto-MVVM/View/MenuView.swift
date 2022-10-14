//
//  MenuView.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 28/09/22.
//

import SwiftUI

struct MenuView: View {

    @ObservedObject var viewModel: MenuViewModelType

    var body: some View {
        Group {
            Button(Constants.Menu.clockIn) {
                viewModel.clockIn()
            }
            .disabled(viewModel.isClockInDisabled)
            .keyboardShortcut("I", modifiers: [.option])

            Button(Constants.Menu.startBreak) {
                viewModel.startBreak()
            }
            .disabled(viewModel.isStartBreakDisabled)
            .keyboardShortcut("B", modifiers: [.option])

            Button(Constants.Menu.resume) {
                viewModel.resume()
            }
            .disabled(viewModel.isResumeDisabled)
            .keyboardShortcut("R", modifiers: [.option])

            Button(Constants.Menu.clockOut) {
                viewModel.clockOut()
            }
            .disabled(viewModel.isClockOutDisabled)
            .keyboardShortcut("O", modifiers: [.option])
        }
        .onAppear {
            viewModel.fetchTimeCard()
        }
    }

}
