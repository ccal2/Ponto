//
//  TimeCardView.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 21/07/22.
//

import SwiftUI

struct TimeCardView: View {

    @ObservedObject var viewModel: TimeCardViewModel

    var body: some View {
        NavigationView {

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
                        HStack {
                            Text(Constants.TimeCardDetails.clockInTimeCellTitle)
                            Spacer()
                            Text(viewModel.clockInText)
                        }

                        HStack {
                            Text(Constants.TimeCardDetails.clockOutTimeCellTitle)
                            Spacer()
                            Text(viewModel.clockOutText)
                        }
                    }

                    // Breaks
                    ForEach(Array(viewModel.breakList.enumerated()), id: \.offset) { (offset, element) in
                        Section(header: Text(String(format: Constants.TimeCardDetails.numberedBreakSectionHeaderTitle, offset + 1))) {
                            BreakListItem(breakListData: element)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                Spacer()
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.large)
        }
        .background(Color(UIColor.systemGroupedBackground)) // NOT WORKING!!!!
        .onAppear {
            viewModel.fetchTimeCard()
        }
    }

}

struct BreakListItem: View {
    var breakListData: BreakListData

    var body: some View {
        HStack {
            Text(Constants.TimeCardDetails.breakStartTimeCellTitle)
            Spacer()
            Text(breakListData.startText)
        }

        HStack {
            Text(Constants.TimeCardDetails.breakEndTimeCellTitle)
            Spacer()
            Text(breakListData.finishText)
        }

        HStack {
            Text(Constants.TimeCardDetails.breakDurationCellTitle)
            Spacer()
            Text(breakListData.durationText)
        }
    }

}

struct TimeCardView_Previews: PreviewProvider {
    static var previews: some View {
        TimeCardView(viewModel: CurrentTimeCardViewModel())
    }
}
