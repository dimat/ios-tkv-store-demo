//
//  DevelopmentEnvironmentTests.swift
//  TKVStoreTests
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import XCTest

@testable import TKVStore

final class DevelopmentEnvironmentTests: XCTestCase {
    var devEnironment: DevelopmentEnviroment!
    var executor: MockProgramExecutor!
    
    override func setUp() {
        executor = MockProgramExecutor()
        devEnironment = DevelopmentEnviroment(executor: executor)
    }
    
    func testInitialState() {
        XCTAssertEqual(devEnironment.logs, [:])
    }
    
    func testRunCallsExecutor() {
        let id = UUID()
        executor.mockRun = { _ in
            [id: .output("hello")]
        }
        
        devEnironment.run()
        
        XCTAssertEqual(devEnironment.logs, [id: .output("hello")])
    }
    
    func testDeleteFirst() {
        let ids = (1...3).map { _ in
            UUID()
        }
        devEnironment.program = .init(commands: [
            .init(id: ids[0], instruction: .begin),
            .init(id: ids[1], instruction: .set(key: "k", value: "v")),
            .init(id: ids[2], instruction: .commit),
        ])
        
        devEnironment.deleteCommand(atOffsets: .init(integer: 0))

        XCTAssertEqual(devEnironment.program.commands, [
            .init(id: ids[1], instruction: .set(key: "k", value: "v")),
            .init(id: ids[2], instruction: .commit),
        ])
    }
    
    func testDeleteMiddle() {
        let ids = (1...3).map { _ in
            UUID()
        }
        devEnironment.program = .init(commands: [
            .init(id: ids[0], instruction: .begin),
            .init(id: ids[1], instruction: .set(key: "k", value: "v")),
            .init(id: ids[2], instruction: .commit),
        ])
        
        devEnironment.deleteCommand(atOffsets: .init(integer: 1))

        XCTAssertEqual(devEnironment.program.commands, [
            .init(id: ids[0], instruction: .begin),
            .init(id: ids[2], instruction: .commit),
        ])
    }
    
    func testDeleteOutside() {
        let ids = (1...3).map { _ in
            UUID()
        }
        devEnironment.program = .init(commands: [
            .init(id: ids[0], instruction: .begin),
            .init(id: ids[1], instruction: .set(key: "k", value: "v")),
            .init(id: ids[2], instruction: .commit),
        ])
        
        devEnironment.deleteCommand(atOffsets: .init(integer: 10))
        XCTAssertEqual(devEnironment.program.commands, [
            .init(id: ids[0], instruction: .begin),
            .init(id: ids[1], instruction: .set(key: "k", value: "v")),
            .init(id: ids[2], instruction: .commit),
        ])
    }
    
    func testMoveCommands() {
        let ids = (1...3).map { _ in
            UUID()
        }
        devEnironment.program = .init(commands: [
            .init(id: ids[0], instruction: .begin),
            .init(id: ids[1], instruction: .set(key: "k", value: "v")),
            .init(id: ids[2], instruction: .commit),
        ])
        
        devEnironment.moveCommand(fromOffsets: .init(integer: 0), toOffset: 2)

        XCTAssertEqual(devEnironment.program.commands, [
            .init(id: ids[1], instruction: .set(key: "k", value: "v")),
            .init(id: ids[0], instruction: .begin),
            .init(id: ids[2], instruction: .commit),
        ])
    }
    
    func testAppendCommand() {
        let id = UUID()
        devEnironment.program = .init(commands: [
            .init(id: id, instruction: .begin),
        ])
        
        let newID = UUID()
        devEnironment.appendCommand(.init(id: newID, instruction: .commit))

        XCTAssertEqual(devEnironment.program.commands, [
            .init(id: id, instruction: .begin),
            .init(id: newID, instruction: .commit),
        ])
    }
    
    func testDeleteCommandClearsLogs() {
        executor.mockRun = { _ in
            [UUID(): .output("hello")]
        }
        
        devEnironment.program = .init(commands: [.init(instruction: .begin)])
        
        devEnironment.run()
        
        devEnironment.deleteCommand(atOffsets: .init(integer: 0))
        
        XCTAssertEqual(devEnironment.logs, [:])
    }
    
    func testAppendCommandClearsLogs() {
        executor.mockRun = { _ in
            [UUID(): .output("hello")]
        }
        
        devEnironment.program = .init(commands: [.init(instruction: .begin)])
        
        devEnironment.run()
        
        devEnironment.appendCommand(.init(instruction: .rollback))
        
        XCTAssertEqual(devEnironment.logs, [:])
    }
    
    func testMoveCommandClearsLogs() {
        executor.mockRun = { _ in
            [UUID(): .output("hello")]
        }
        
        devEnironment.program = .init(commands: [.init(instruction: .begin), .init(instruction: .commit)])
        
        devEnironment.run()
        
        devEnironment.moveCommand(fromOffsets: .init(integer: 1), toOffset: 0)
        
        XCTAssertEqual(devEnironment.logs, [:])
    }
    
    func testReplaceProgramClearsLogs() {
        executor.mockRun = { _ in
            [UUID(): .output("hello")]
        }
        
        devEnironment.program = .init(commands: [.init(instruction: .begin), .init(instruction: .commit)])
        
        devEnironment.run()
        
        devEnironment.program = .init(commands: [.init(instruction: .commit)])
        
        XCTAssertEqual(devEnironment.logs, [:])
    }
}
