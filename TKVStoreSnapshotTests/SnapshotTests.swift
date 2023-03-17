//
//  ProgramViewTests.swift
//  TKVStoreSnapshotTests
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import XCTest
import PreviewSnapshotsTesting

@testable import TKVStore

final class SnapshotTests: XCTestCase {
    func testProgramView() {
        ProgramView_Previews.snapshots.assertSnapshots(as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testCommandView() {
        CommandView_Previews.snapshots.assertSnapshots(as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testExecutionLogView() {
        ExecutionLogView_Previews.snapshots.assertSnapshots(as: .image(layout: .device(config: .iPhone13)))
    }
    
    func testNewInstructionView() {
        NewInstructionView_Previews.snapshots.assertSnapshots(as: .image(layout: .device(config: .iPhone13)))
    }
}
