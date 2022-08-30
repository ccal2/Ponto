//
//  TimeCardHistoryView.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 29/08/22.
//

import SwiftUI

struct TimeCardHistoryView: View {

    @ObservedObject var viewModel: TimeCardHistoryViewModelType

    var body: some View {
        Group {
            if viewModel.timeCardsGroupedByMonth.isEmpty {
                Text(Constants.TimeCardHistory.emptyHistoryMessage)
            } else {
                // Table view
                List {
                    // Months
                    ForEach(Array(viewModel.timeCardsGroupedByMonth), id: \.key) { element in
                        Section(header: Text(element.key)) {
                            ForEach(Array(element.value.enumerated()), id: \.offset) { _, timeCardListData in
                                NavigationLink {
                                    TimeCardView(viewModel: CurrentTimeCardViewModel())
                                } label: {
                                    TimeCardListItem(timeCardListData: timeCardListData)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.fetchTimeCards()
        }
    }

}

struct TimeCardListItem: View {
    var timeCardListData: TimeCardListData

    var body: some View {
        SimpleListItem(title: timeCardListData.dateText,
                       detail: timeCardListData.durationText)
    }

}

struct TimeCardHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimeCardHistoryView(viewModel: TimeCardHistoryViewModel())
        }
    }
}
