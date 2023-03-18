//
//  Storage.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import Foundation

enum Operation: String, CaseIterable, Equatable {
    case set
    case get
    case delete
    case count
    case begin
    case commit
    case rollback
}

extension Operation {
    var title: String {
        self.rawValue.uppercased()
    }
}

enum Instruction: Equatable, Hashable {
    case set(key: String, value: String)
    case get(key: String)
    case delete(key: String)
    case count(value: String)
    case begin
    case commit
    case rollback
}

extension Instruction {
    var operation: Operation {
        switch self {
        case .set: return .set
        case .get: return .get
        case .delete: return .delete
        case .count: return .count
        case .begin: return .begin
        case .commit: return .commit
        case .rollback: return .rollback
        }
    }
}

struct Command: Identifiable, Equatable, Hashable {
    let id: UUID
    var instruction: Instruction
    
    init(id: UUID, instruction: Instruction) {
        self.id = id
        self.instruction = instruction
    }
    
    init(instruction: Instruction) {
        self.id = UUID()
        self.instruction = instruction
    }
}

protocol Storage {
    func perform(instruction: Instruction) -> ExecutionLog?
    func reset()
}
