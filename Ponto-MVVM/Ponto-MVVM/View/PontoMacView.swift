//
//  PontoMacView.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 12/09/22.
//

import SwiftUI

struct PontoMacView: View {

    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    TimeCardView(viewModel: CurrentTimeCardViewModel())
                } label: {
                    Label(Constants.CurrentTimeCard.tabBarTitle, systemImage: Constants.ImageName.calendarIcon)
                }

                NavigationLink {
                    TimeCardHistoryView(viewModel: TimeCardHistoryViewModel())
                } label: {
                    Label(Constants.TimeCardHistory.screenTitle, systemImage: Constants.ImageName.clockIcon)
                }
            }
            .listStyle(.sidebar)
        }
    }

}

struct PontoMacView_Previews: PreviewProvider {
    static var previews: some View {
        PontoMacView()
    }
}
