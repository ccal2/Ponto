//
//  PontoViewControllersSnapshotTests.swift
//  Ponto-MVCSnapshotTests
//
//  Created by Carolina Cruz Agra Lopes on 03/21/22.
//

import XCTest
import SnapshotTesting
import SnapshotTestingStitch

@testable import Ponto_MVC

class PontoViewControllersSnapshotTests: XCTestCase {

    func test_CurrentTimeCardViewController_noTimeCard() throws {
        let recordMode = false

        let viewController = CurrentTimeCardViewController()
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .light, orientation: .portrait)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .light, orientation: .landscape)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .dark, orientation: .portrait)
        assertViewControllerSnapshot(matching: viewController, record: recordMode, interfaceStyle: .dark, orientation: .landscape)
    }

}
