//
//  TimeCardView.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 21/07/22.
//

import SwiftUI

struct TimeCardView: View {

    @ObservedObject var viewModel: TimeCardViewModelType

    var body: some View {
        VStack {
            // Duration text
            Text(viewModel.durationText)
                .font(.system(size: 72.0, design: .monospaced))
                .fontWeight(.light)

            // Break text
            Group {
                if let breakText = viewModel.breakText {
                    Text(breakText)
                } else {
                    // Set hidden Text view to keep space for break label
                    Text(Constants.TimeCardDetails.durationPlaceholder)
                        .hidden()
                }
            }
            .font(.system(size: 22.0, design: .monospaced))

            // Control buttons
            if let pauseResumeButtonImageName = viewModel.pauseResumeButtonImageName,
               let startStopButtonImageName = viewModel.startStopButtonImageName {
                HStack(spacing: Constants.ViewSpacing.large) {
                    Group {
                        Button {
                            viewModel.pauseOrResumeTimeCard()
                        } label: {
                            Image(systemName: pauseResumeButtonImageName)
                                .resizable()
                        }
                        .disabled(viewModel.isPauseResumeButtonDisabled)

                        Button {
                            viewModel.startOrStopTimeCard()
                        } label: {
                            Image(systemName: startStopButtonImageName)
                                .resizable()
                        }
                        .disabled(viewModel.isStartStopButtonDisabled)
                    }
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: Constants.ViewSpacing.extraLarge)
                    .accentColor(.gray)
                }
            }

            // Table view
            List {
                // Clock in / Clock out
                Section(header: Text("")) {
                    SimpleListItem(title: Constants.TimeCardDetails.clockInTimeCellTitle,
                                   detail: viewModel.clockInText)

                    SimpleListItem(title: Constants.TimeCardDetails.clockOutTimeCellTitle,
                                   detail: viewModel.clockOutText)
                }

                // Breaks
                ForEach(Array(viewModel.breakList.enumerated()), id: \.offset) { offset, element in
                    Section(header: Text(String(format: Constants.TimeCardDetails.numberedBreakSectionHeaderTitle, offset + 1))) {
                        BreakListItem(breakListData: element)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(viewModel.isTitleLarge ? .large : .inline)
        .onAppear {
            viewModel.fetchTimeCard()
        }
    }

}

struct BreakListItem: View {
    var breakListData: BreakListData

    var body: some View {
        SimpleListItem(title: Constants.TimeCardDetails.breakStartTimeCellTitle,
                       detail: breakListData.startText)

        SimpleListItem(title: Constants.TimeCardDetails.breakEndTimeCellTitle,
                       detail: breakListData.finishText)

        SimpleListItem(title: Constants.TimeCardDetails.breakDurationCellTitle,
                       detail: breakListData.durationText)
    }

}

struct TimeCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimeCardView(viewModel: CurrentTimeCardViewModel())
        }
        .previewDisplayName("Current")

        NavigationView {
            TimeCardView(viewModel: TimeCardDetailViewModel(timeCard: timeCardSample))
        }
        .previewDisplayName("Detail")
    }
}

let timeCardSample = TimeCard(start: Date(timeIntervalSince1970: 8 * Constants.TimeConversion.hoursToSeconds),
                              end: Date(timeIntervalSince1970: 17 * Constants.TimeConversion.hoursToSeconds),
                              breaks: [
                                Break(start: Date(timeIntervalSince1970: 12 * Constants.TimeConversion.hoursToSeconds),
                                      end: Date(timeIntervalSince1970: 13 * Constants.TimeConversion.hoursToSeconds))
                              ])
