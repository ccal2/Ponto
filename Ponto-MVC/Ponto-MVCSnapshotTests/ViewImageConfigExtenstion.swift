//
//  ViewImageConfigExtenstion.swift
//  Ponto-MVCSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 22/05/22.
//

// An extension to add devices not currently present in the SnapshotTesting package.
// The sizes were taken from https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/adaptivity-and-layout/
// The safe areas for each device was not found, so we're using the same as the one for iPhone X as declared in the SnapshotTesting package.

import SnapshotTesting
import UIKit

extension ViewImageConfig {

    public static let iPhone11 = ViewImageConfig.iPhoneX(.portrait)

    public static func iPhone11(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 0, right: 44)
            size = .init(width: 896, height: 414)
        case .portrait:
            safeArea = .init(top: 0, left: 0, bottom: 34, right: 0)
            size = .init(width: 414, height: 896)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
    }

    public static let iPhone11Pro = ViewImageConfig.iPhoneX(.portrait)

    public static func iPhone11Pro(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 24, right: 44)
            size = .init(width: 812, height: 375)
        case .portrait:
            safeArea = .init(top: 0, left: 0, bottom: 34, right: 0)
            size = .init(width: 375, height: 812)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
    }

    public static let iPhone12 = ViewImageConfig.iPhoneX(.portrait)

    public static func iPhone12(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 0, right: 44)
            size = .init(width: 844, height: 390)
        case .portrait:
            safeArea = .init(top: 0, left: 0, bottom: 34, right: 0)
            size = .init(width: 390, height: 844)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
    }

    public static let iPhone12Pro = ViewImageConfig.iPhoneX(.portrait)

    public static func iPhone12Pro(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 0, right: 44)
            size = .init(width: 844, height: 390)
        case .portrait:
            safeArea = .init(top: 0, left: 0, bottom: 34, right: 0)
            size = .init(width: 390, height: 844)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
    }

    public static let iPhone13 = ViewImageConfig.iPhoneX(.portrait)

    public static func iPhone13(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 0, right: 44)
            size = .init(width: 844, height: 390)
        case .portrait:
            safeArea = .init(top: 0, left: 0, bottom: 34, right: 0)
            size = .init(width: 390, height: 844)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
    }

    public static let iPhone13Pro = ViewImageConfig.iPhoneX(.portrait)

    public static func iPhone13Pro(_ orientation: Orientation) -> ViewImageConfig {
        let safeArea: UIEdgeInsets
        let size: CGSize
        switch orientation {
        case .landscape:
            safeArea = .init(top: 0, left: 44, bottom: 0, right: 44)
            size = .init(width: 844, height: 390)
        case .portrait:
            safeArea = .init(top: 0, left: 0, bottom: 34, right: 0)
            size = .init(width: 390, height: 844)
        }
        return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
    }

}
