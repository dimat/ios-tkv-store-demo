//
//  InMemoryStorage.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import Foundation

class InMemoryStorage: Storage {
    typealias State = [String: String?]
    private var transactionsStack: [State] = [[:]]
    
    init() {
    }
    
    func reset() {
        transactionsStack = [[:]]
    }
    
    @discardableResult
    func perform(instruction: Instruction) -> ExecutionLog? {
        switch instruction {
        case .set(let key, let value):
            applyState(subState: [key: value])
            
        case .get(let key):
            guard let value = recursiveFind(key: key) else {
                return .warning("key not set")
            }
            return .output(value)
            
        case .delete(let key):
            applyState(subState: [key: nil])
            
        case .count(let searchValue): ()
            let result = mergedTransactions().reduce(0) { $0 + (searchValue == $1.value ? 1 : 0) }
            return .output(result.formatted())
            
        case .begin:
            transactionsStack.append([:])
            
        case .commit:
            guard transactionsStack.count > 1, let last = transactionsStack.popLast() else {
                return .warning("no transaction")
            }
            applyState(subState: last)
            
        case .rollback:
            guard transactionsStack.count > 1, transactionsStack.popLast() != nil else {
                return .warning("no transaction")
            }
        }
        
        return nil
    }
    
    private func mergedTransactions() -> State {
        transactionsStack.reduce(State()) { partialResult, subState in
            return partialResult.merging(subState, uniquingKeysWith: { current, new in new })
        }
    }
    
    private func recursiveFind(key: String) -> String? {
        transactionsStack
            .reversed()
            .first { subState in
                subState.contains(where: { $0.key == key })
            }?
            .first(where: { $0.key == key })?
            .value
    }
    
    private var currentState: State {
        guard let last = transactionsStack.last else {
            fatalError("internal developer's error")
        }
        return last
    }
    
    private func replaceCurrentState(_ state: State) {
        transactionsStack.removeLast()
        transactionsStack.append(transactionsStack.isEmpty ? state.filter({ $0.value != nil}) : state)
    }
    
    private func applyState(subState: State) {
        let newState = currentState.merging(subState) { current, new in new }
        
        replaceCurrentState(newState)
    }
}
