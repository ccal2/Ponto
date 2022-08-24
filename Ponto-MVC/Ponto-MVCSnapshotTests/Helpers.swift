//
//  Helpers.swift
//  Ponto-MVCSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 03/22/22.
//

import UIKit
import SnapshotTesting
import SnapshotTestingStitch
import XCTest

let viewControllerSnapshotLightStyle = StitchStyle(borderColor: .clear)
let viewControllerSnapshotDarkStyle = StitchStyle(titleColor: .black,
                                                  borderColor: .clear,
                                                  backgroundColor: .white)

func assertViewControllerSnapshot(
    matching value: @autoclosure () throws -> UIViewController,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line,
    interfaceStyle: UIUserInterfaceStyle = .light,
    orientation: ViewImageConfig.Orientation = .portrait
) {
    guard let viewController = try? value() else {
        XCTFail()
        return
    }

    viewController.overrideUserInterfaceStyle = interfaceStyle

    let style = interfaceStyle == .light ? viewControllerSnapshotLightStyle : viewControllerSnapshotDarkStyle

    let namePostfix = snapshotNamePostfix(interfaceStyle: interfaceStyle, orientation: orientation)
    let finalName: String
    if let name = name {
        finalName = name + "_" + namePostfix
    } else {
        finalName = namePostfix
    }

    assertSnapshot(matching: viewController,
                   as: .stitch(strategies: snapshotStrategies(orientation: orientation), style: style),
                   named: finalName,
                   record: recording,
                   timeout: timeout,
                   file: file,
                   testName: testName,
                   line: line)

}

private func snapshotStrategies(orientation: ViewImageConfig.Orientation) -> [(String, Snapshotting<UIViewController, UIImage>)] {
    let orientationIndicator = orientation == .portrait ? "|" : "-"

    return [
        ("iPhone X (\(orientationIndicator))", .image(on: .iPhoneX(orientation))),
        ("iPhone 11 (\(orientationIndicator))", .image(on: .iPhone11(orientation))),
        // iPhone XR, iPhone XS Max and iPhone 11 have the same dimensions, so they're not repeated here
        ("iPhone 11 Pro (\(orientationIndicator))", .image(on: .iPhone11Pro(orientation))),
        ("iPhone 12 (\(orientationIndicator))", .image(on: .iPhone12(orientation)))
        // iPhone 12, iPhone 12 Pro, iPhone 13 and iPhone 13 Pro have the same dimensions, so they're not repeated here
    ]
}

private func snapshotNamePostfix(interfaceStyle: UIUserInterfaceStyle, orientation: ViewImageConfig.Orientation) -> String {
    let nameOrientationPostfix = orientation == .portrait ? "Portrait" : "Landscape"
    let nameInterfacePostfix = interfaceStyle == .light ? "Light" : "Dark"

    return nameOrientationPostfix + "_" + nameInterfacePostfix
}
