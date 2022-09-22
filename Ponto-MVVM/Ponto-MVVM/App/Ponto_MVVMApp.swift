//
//  Ponto_MVVMApp.swift
//  Ponto-MVVM
//
//  Created by Carolina Cruz Agra Lopes on 20/07/22.
//

import SwiftUI

@main
struct Ponto_MVVMApp: App {
    var body: some Scene {
        WindowGroup {
            #if targetEnvironment(macCatalyst)
            PontoMacView()
            #else
            PontoView()
            #endif
        }
    }
}
