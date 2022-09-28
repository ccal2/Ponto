//
//  PontoView.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 12/09/22.
//

import SwiftUI

struct PontoView: View {

    var body: some View {
        TabView {
            EmbeddedViewInNavigation {
                AnyView(TimeCardView(viewModel: CurrentTimeCardViewModel()))
            }
            .tabItem {
                Image(systemName: Constants.ImageName.calendarIcon)
                Text(Constants.CurrentTimeCard.tabBarTitle)
            }

            EmbeddedViewInNavigation {
                AnyView(TimeCardHistoryView(viewModel: TimeCardHistoryViewModel()))
            }
            .tabItem {
                Image(systemName: Constants.ImageName.clockIcon)
                Text(Constants.TimeCardHistory.screenTitle)
            }
        }
        .navigationViewStyle(.stack)
    }

}

struct PontoView_Previews: PreviewProvider {
    static var previews: some View {
        PontoView()
    }
}
