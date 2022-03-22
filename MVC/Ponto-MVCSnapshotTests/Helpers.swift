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
    ("iPhone SE (|)", .image(on: .iPhoneSe(.portrait))),
    ("iPhone 8 (|)", .image(on: .iPhone8(.portrait))),
    ("iPhone 8 Plus (|)", .image(on: .iPhone8Plus(.portrait))),
    ("iPhone X (|)", .image(on: .iPhoneX(.portrait))),
    ("iPhone XR (|)", .image(on: .iPhoneXr(.portrait))),
    ("iPhone XS Max (|)", .image(on: .iPhoneXsMax(.portrait)))
]

let viewControllerLandscapeSnapshotStrategies: [(name: String, strategy: Snapshotting<UIViewController, UIImage>)] = [
    ("iPhone SE (-)", .image(on: .iPhoneSe(.landscape))),
    ("iPhone 8 (-)", .image(on: .iPhone8(.landscape))),
    ("iPhone 8 Plus (-)", .image(on: .iPhone8Plus(.landscape))),
    ("iPhone X (-)", .image(on: .iPhoneX(.landscape))),
    ("iPhone XR (-)", .image(on: .iPhoneXr(.landscape))),
    ("iPhone XS Max (-)", .image(on: .iPhoneXsMax(.landscape)))
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
