//
//  CodableView.swift
//  Ponto-MVC
//
//  Created by Carolina Cruz Agra Lopes on 03/22/22.
//

import UIKit

protocol CodableView: UIView {
    func buildViewHierarchy()
    func setupContraints()
    func setupAdditionalConfiguration()
    func setupView()
}

extension CodableView {
    func setupView() {
        buildViewHierarchy()
        setupContraints()
        setupAdditionalConfiguration()
    }
}
