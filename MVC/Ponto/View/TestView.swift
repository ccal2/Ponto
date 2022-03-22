//
//  TestView.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 03/21/22.
//

import UIKit
import SnapKit

class TestView: UIView {

    // MARK: - Subviews

    lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = "label"
        return view
    }()

    lazy var countLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = "no taps yet"
        return view
    }()

    lazy var button: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Tap me!", for: .normal)
        return view
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - CodableView

extension TestView: CodableView {

    func setupView() {
        buildViewHierarchy()
        setupContraints()
        setupAdditionalConfiguration()
    }

    func buildViewHierarchy() {
        addSubviews([
            label,
            countLabel,
            button
        ])
    }

    func setupContraints() {
        label.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.centerX.equalTo(self)
        }

        countLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(label.snp.bottom).offset(16)
            make.centerX.equalTo(self)
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(8)
            make.centerX.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }

    func setupAdditionalConfiguration() {
        backgroundColor = .systemBackground
    }

}
