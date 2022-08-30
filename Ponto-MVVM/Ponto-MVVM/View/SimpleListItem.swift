//
//  SimpleListItem.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 30/08/22.
//

import SwiftUI

struct SimpleListItem: View {
    let title: String
    let detail: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(detail)
                .foregroundColor(.secondary)
        }
    }

}

struct SimpleListItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(0 ..< 5) { _ in
                SimpleListItem(title: "Title", detail: "detail")
            }
        }
    }
}
