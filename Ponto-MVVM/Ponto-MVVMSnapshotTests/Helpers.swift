//
//  Helpers.swift
//  Ponto-MVVMSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 23/08/22.
//

import SwiftUI
import SnapshotTesting
import SnapshotTestingStitch
import XCTest

@testable import Ponto_MVVM

let viewSnapshotLightStyle = StitchStyle(borderColor: .clear)
let viewSnapshotDarkStyle = StitchStyle(titleColor: .black,
                                        borderColor: .clear,
                                        backgroundColor: .white)

func assertViewSnapshot<Value: View>(
    matching value: @autoclosure () throws -> Value,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line,
    interfaceStyle: UIUserInterfaceStyle = .light,
    orientation: ViewImageConfig.Orientation = .portrait
) {
    guard let view = try? value() else {
        XCTFail()
        return
    }

    let style = interfaceStyle == .light ? viewSnapshotLightStyle : viewSnapshotDarkStyle

    let namePostfix = snapshotNamePostfix(interfaceStyle: interfaceStyle, orientation: orientation)
    let finalName: String
    if let name = name {
        finalName = name + "_" + namePostfix
    } else {
        finalName = namePostfix
    }

    assertSnapshot(matching: view,
                   as: .stitch(strategies: snapshotStrategies(interfaceStyle: interfaceStyle, orientation: orientation), style: style),
                   named: finalName,
                   record: recording,
                   timeout: timeout,
                   file: file,
                   testName: testName,
                   line: line)

}

private func snapshotStrategies<Value: View>(interfaceStyle: UIUserInterfaceStyle, orientation: ViewImageConfig.Orientation) -> [(String, Snapshotting<Value, UIImage>)] {
    let orientationIndicator = orientation == .portrait ? "|" : "-"
    let traits = UITraitCollection(userInterfaceStyle: interfaceStyle)

    return [
        ("iPhone X (\(orientationIndicator))", .image(layout: .device(config: .iPhoneX(orientation)), traits: traits)),
        ("iPhone 11 (\(orientationIndicator))", .image(layout: .device(config: .iPhone11(orientation)), traits: traits)),
        // iPhone XR, iPhone XS Max and iPhone 11 have the same dimensions, so they're not repeated here
        ("iPhone 11 Pro (\(orientationIndicator))", .image(layout: .device(config: .iPhone11Pro(orientation)), traits: traits)),
        ("iPhone 12 (\(orientationIndicator))", .image(layout: .device(config: .iPhone12(orientation)), traits: traits))
        // iPhone 12, iPhone 12 Pro, iPhone 13 and iPhone 13 Pro have the same dimensions, so they're not repeated here
    ]
}

private func snapshotNamePostfix(interfaceStyle: UIUserInterfaceStyle, orientation: ViewImageConfig.Orientation) -> String {
    let nameOrientationPostfix = orientation == .portrait ? "Portrait" : "Landscape"
    let nameInterfacePostfix = interfaceStyle == .light ? "Light" : "Dark"

    return nameOrientationPostfix + "_" + nameInterfacePostfix
}

struct EmbeddedViewInNavigation: View {

    let embeddedView: AnyView

    var body: some View {
        NavigationView {
            embeddedView
        }
    }

}
