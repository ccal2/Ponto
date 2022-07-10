//
//  CurrentTimeCardView.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 04/03/22.
//

import SnapKit
import UIKit

protocol CurrentTimeCardViewDelegate: AnyObject {
    func currentTimeCardView(_ view: CurrentTimeCardView, didTapStartStopButton button: UIButton)
    func currentTimeCardView(_ view: CurrentTimeCardView, didTapPauseContinueButton button: UIButton)
}

class CurrentTimeCardView: UIView {

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

    lazy var pauseContinueButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        view.tintColor = UIColor.systemGray
        view.isEnabled = false
        return view
    }()

    lazy var startStopButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        view.tintColor = UIColor.systemGray
        view.isEnabled = true
        return view
    }()

    lazy var buttonsStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [pauseContinueButton, startStopButton])
        view.axis = .horizontal
        view.spacing = CGFloat(Constants.ViewSpacing.large)
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

    // MARK: - Actions

    @objc func tappedStartStopButton(sender: UIButton) {
        delegate?.currentTimeCardView(self, didTapStartStopButton: sender)
    }

    @objc func tappedPauseContinueButton(sender: UIButton) {
        delegate?.currentTimeCardView(self, didTapPauseContinueButton: sender)
    }

}

// MARK: - CodableView

extension CurrentTimeCardView: CodableView {

    func buildViewHierarchy() {
        addSubviews([
            durationLabel,
            breakLabel,
            buttonsStack,
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

        buttonsStack.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(breakLabel.snp.bottom).offset(Constants.ViewSpacing.small)
            make.top.equalTo(breakLabel.snp.bottom).offset(Constants.ViewSpacing.medium).priority(.medium)
            make.top.lessThanOrEqualTo(breakLabel.snp.bottom).offset(Constants.ViewSpacing.large)
            make.centerX.equalTo(self)
        }

        pauseContinueButton.snp.makeConstraints { make in
            make.width.equalTo(pauseContinueButton.snp.height)
            make.width.equalTo(Constants.ViewSpacing.extraExtraLarge).priority(.high)
        }

        startStopButton.snp.makeConstraints { make in
            make.width.equalTo(startStopButton.snp.height)
            make.width.equalTo(pauseContinueButton)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(buttonsStack.snp.bottom)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

    func setupAdditionalConfiguration() {
        backgroundColor = .systemGroupedBackground

        pauseContinueButton.addTarget(self, action: #selector(tappedPauseContinueButton), for: .touchUpInside)
        startStopButton.addTarget(self, action: #selector(tappedStartStopButton), for: .touchUpInside)

        tableView.register(TimeCardDetailTableViewCell.self, forCellReuseIdentifier: TimeCardDetailTableViewCell.reuseIdentifier)
    }

}
