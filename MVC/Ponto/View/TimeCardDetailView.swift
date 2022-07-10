//
//  TimeCardDetailView.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 09/07/22.
//

import SnapKit
import UIKit

class TimeCardDetailView: UIView {

    // MARK: - Subviews

    lazy var durationLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.monospacedDigitSystemFont(ofSize: 72.0, weight: .light)
        view.text = Constants.TimeCardDetails.durationPlaceholder
        return view
    }()

    lazy var breakLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.monospacedDigitSystemFont(ofSize: 22.0, weight: .regular)
        view.text = "on a break for --:--:--"
        view.numberOfLines = 2
        view.isHidden = true
        return view
    }()

    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        return view
    }()

    // MARK: - Delegate

    weak var delegate: CurrentTimeCardViewDelegate?

    // MARK: - Initializers

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - CodableView

extension TimeCardDetailView: CodableView {

    func buildViewHierarchy() {
        addSubviews([
            durationLabel,
            breakLabel,
            tableView
        ])
    }

    func setupContraints() {
        durationLabel.setContentHuggingPriority(.required, for: .vertical)
        durationLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(safeAreaLayoutGuide).offset(Constants.ViewSpacing.small)
            make.top.equalTo(safeAreaLayoutGuide).offset(Constants.ViewSpacing.large).priority(.medium)
            make.top.lessThanOrEqualTo(safeAreaLayoutGuide).offset(Constants.ViewSpacing.large)
            make.centerX.equalTo(self)
        }

        breakLabel.setContentHuggingPriority(.required, for: .vertical)
        breakLabel.snp.makeConstraints { make in
            make.top.equalTo(durationLabel.snp.bottom)
            make.leading.greaterThanOrEqualTo(safeAreaLayoutGuide).offset(Constants.ViewSpacing.large)
            make.centerX.equalTo(self)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(breakLabel.snp.bottom)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    func setupAdditionalConfiguration() {
        backgroundColor = .systemGroupedBackground

        tableView.register(TimeCardDetailTableViewCell.self, forCellReuseIdentifier: TimeCardDetailTableViewCell.reuseIdentifier)
    }

}
