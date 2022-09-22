//
//  EmbeddedViewInNavigation.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 31/08/22.
//

import SwiftUI

struct EmbeddedViewInNavigation: View {

    let embeddedView: () -> AnyView

    var body: some View {
        NavigationView {
            embeddedView()
        }
    }

}
