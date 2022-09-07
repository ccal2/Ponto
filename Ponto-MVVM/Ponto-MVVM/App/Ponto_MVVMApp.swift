//
//  Ponto_MVVMApp.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 20/07/22.
//

import SwiftUI

@main
struct Ponto_MVVMApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                EmbeddedViewInNavigation(embeddedView: AnyView(TimeCardView(viewModel: CurrentTimeCardViewModel())))
                    .tabItem {
                        Image(systemName: Constants.ImageName.calendarIcon)
                        Text(Constants.CurrentTimeCard.tabBarTitle)
                    }
                EmbeddedViewInNavigation(embeddedView: AnyView(TimeCardHistoryView(viewModel: TimeCardHistoryViewModel())))
                    .tabItem {
                        Image(systemName: Constants.ImageName.clockIcon)
                        Text(Constants.TimeCardHistory.screenTitle)
                    }
            }
        }
    }
}
