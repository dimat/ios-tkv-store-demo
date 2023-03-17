//
//  DevelopmentEnviroment.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import Foundation
import Combine

class DevelopmentEnviroment: ObservableObject {
    @Published var program: Program {
        didSet {
            clearLogs()
        }
    }
    @Published private(set) var logs: [Command.ID: ExecutionLog] = [:]
    
    private var executor: any ProgramExecutorProtocol
    
    init(executor: any ProgramExecutorProtocol) {
        self.executor = executor
        self.program = .init(commands: [])
    }
    
    func clearLogs() {
        if logs.isEmpty {
            return
        }
        logs = [:]
    }
       
    func moveCommand(fromOffsets: IndexSet, toOffset: Int) {
        program.commands.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func appendCommand(_ command: Command) {
        program.commands.append(command)
    }
    
    func deleteCommand(atOffsets: IndexSet) {
        program.commands.remove(atOffsets: atOffsets)
    }
    
    func run() {
        logs = executor.run(program: program)
    }
}
