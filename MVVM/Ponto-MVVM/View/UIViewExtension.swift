//
//  UIViewExtension.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 03/22/22.
//

import UIKit

extension UIView {

    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { view in addSubview(view) }
    }

}
