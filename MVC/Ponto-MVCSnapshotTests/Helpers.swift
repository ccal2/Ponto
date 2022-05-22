//
//  Helpers.swift
//  Ponto-MVCSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 03/22/22.
//

import UIKit
import SnapshotTesting
import SnapshotTestingStitch

let viewControllerPortraitSnapshotStrategies: [(name: String, strategy: Snapshotting<UIViewController, UIImage>)] = [
    ("iPhone X (|)", .image(on: .iPhoneX(.portrait))),
    ("iPhone 11 (|)", .image(on: .iPhone11(.portrait))),
    // iPhone XR, iPhone XS Max and iPhone 11 have the same dimensions, so they're not repeared here
    ("iPhone 11 Pro (|)", .image(on: .iPhone11Pro(.portrait))),
    ("iPhone 12 (|)", .image(on: .iPhone12(.portrait)))
    // iPhone 12, iPhone 12 Pro, iPhone 13 and iPhone 13 Pro have the same dimensions, so they're not repeared here
]

let viewControllerLandscapeSnapshotStrategies: [(name: String, strategy: Snapshotting<UIViewController, UIImage>)] = [
    ("iPhone X (-)", .image(on: .iPhoneX(.landscape))),
    ("iPhone 11 (-)", .image(on: .iPhone11(.landscape))),
    // iPhone XR, iPhone XS Max and iPhone 11 have the same dimensions, so they're not repeared here
    ("iPhone 11 Pro (-)", .image(on: .iPhone11Pro(.landscape))),
    ("iPhone 12 (-)", .image(on: .iPhone12(.landscape)))
    // iPhone 12, iPhone 12 Pro, iPhone 13 and iPhone 13 Pro have the same dimensions, so they're not repeared here
]

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
    let viewController = try! value()
    viewController.overrideUserInterfaceStyle = interfaceStyle

    let style = interfaceStyle == .light ? viewControllerSnapshotLightStyle : viewControllerSnapshotDarkStyle
    let strategies = orientation == .portrait ? viewControllerPortraitSnapshotStrategies : viewControllerLandscapeSnapshotStrategies

    let namePostfix = snapshotNamePostfix(interfaceStyle: interfaceStyle, orientation: orientation)
    let finalName: String
    if let name = name {
        finalName = name + "_" + namePostfix
    } else {
        finalName = namePostfix
    }

    // Portrait (|)
    assertSnapshot(matching: viewController,
                   as: .stitch(strategies: strategies, style: style),
                   named: finalName,
                   record: recording,
                   timeout: timeout,
                   file: file,
                   testName: testName,
                   line: line)

}

fileprivate func snapshotNamePostfix(interfaceStyle: UIUserInterfaceStyle, orientation: ViewImageConfig.Orientation) -> String {
    let nameOrientationPostfix = orientation == .portrait ? "Portrait" : "Landscape"
    let nameInterfacePostfix = interfaceStyle == .light ? "Light" : "Dark"

    return nameOrientationPostfix + "_" + nameInterfacePostfix
}
