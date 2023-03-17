//
//  PrograrmExecutor.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import Foundation

enum ExecutionLog: Equatable {
    case warning(String) // instead of string, it can be a set of predefined errors
    case output(String)
}

protocol ProgramExecutorProtocol {
    func run(program: Program) -> [Command.ID: ExecutionLog]
}

class ProgramExecutor: ProgramExecutorProtocol {
    private let storage: any Storage
    
    init(storage: any Storage) {
        self.storage = storage
    }
    
    func run(program: Program) -> [Command.ID: ExecutionLog] {
        storage.reset()
        
        return program.commands
            .compactMap { command -> (id: Command.ID, log: ExecutionLog)? in
                guard let log = storage.perform(instruction: command.instruction) else {
                    return nil
                }
                return (id: command.id, log: log)
            }
            .reduce([Command.ID: ExecutionLog]()) { $0.merging([$1.id: $1.log], uniquingKeysWith: { (_, new) in new }) }
    }
}

class MockProgramExecutor: ProgramExecutorProtocol {
    init() {}
    
    var mockRun: ((Program) -> [Command.ID: ExecutionLog])?
    func run(program: Program) -> [Command.ID: ExecutionLog] {
        mockRun?(program) ?? [:]
    }
}
