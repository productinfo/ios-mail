//
//  TrashTests.swift
//  ProtonMailUITests
//
//  Created by mirage chung on 2020/12/25.
//  Copyright © 2020 Proton Mail. All rights reserved.
//

import XCTest

import ProtonCore_TestingToolkit

class TrashTests: FixtureAuthenticatedTestCase {

    func testDeleteSingleMessageFromLongClick() {
        runTestWithScenario(.trashOneMessage) {
            InboxRobot()
                .longClickMessageBySubject(scenario.subject)
                .moveToTrash()
                .menuDrawer()
                .trash()
                .verify.messageExists(scenario.subject)
        }
    }
    
    func testDeleteMessageFromDetailPage() {
        runTestWithScenario(.trashOneMessage) {
            InboxRobot()
                .clickMessageBySubject(scenario.subject)
                .moveToTrash()
                .menuDrawer()
                .trash()
                .verify.messageExists(scenario.subject)
        }
    }

    func testDeleteMultipleMessages() {
        runTestWithScenario(.trashMultipleMessages) {
            InboxRobot()
                .selectMultipleMessages([0,2])
                .moveToTrash()
                .menuDrawer()
                .trash()
                .verify.numberOfMessageExists(2)
        }
    }

    func testClearTrashFolder() {
        runTestWithScenario(.trashMultipleMessages) {
            InboxRobot()
                .selectMultipleMessages([0,1])
                .moveToTrash()
                .menuDrawer()
                .trash()
                .clearTrashFolder()
                .verify.nothingToSeeHere()
        }
    }
}
