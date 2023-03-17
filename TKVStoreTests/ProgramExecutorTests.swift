//
//  ProgramExecutorTests.swift
//  TKVStoreTests
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import XCTest

@testable import TKVStore

final class ProgramExecutorTests: XCTestCase {
    var storage: MockStorage!
    var executor: ProgramExecutor!
    
    override func setUp() {
        storage = MockStorage()
        executor = ProgramExecutor(storage: storage)
    }
    
    func testResetBeforeExecution() {
        let didResetExpectation = expectation(description: "did reset")
        storage.mockReset = {
            didResetExpectation.fulfill()
        }
        
        _ = executor.run(program: .init(commands: []))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testEmptyProgram() {
        storage.mockPerform = { _ in
            return .output("test")
        }
        
        let logs = executor.run(program: .init(commands: []))
        XCTAssertEqual(logs, [:])
    }
    
    func testSkipsEmptyLogs() {
        storage.mockPerform = { _ in
            return nil
        }
        
        let logs = executor.run(program: .init(commands: [.init(instruction: .set(key: "k1", value: "v1"))]))
        XCTAssertEqual(logs, [:])
    }
    
    
    func testKeepsLogs() {
        storage.mockPerform = { instruction in
            return .output("out \(instruction.operation.title)")
        }
        
        let commands = [
            Command(instruction: .set(key: "k1", value: "v1")),
            Command(instruction: .get(key: "k1")),
            Command(instruction: .delete(key: "k1"))
        ]
        
        let logs = executor.run(program: .init(commands: commands))
        XCTAssertEqual(logs, [
            commands[0].id: .output("out SET"),
            commands[1].id: .output("out GET"),
            commands[2].id: .output("out DELETE")
        ])
    }
}
