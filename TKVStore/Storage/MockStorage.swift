//
//  MockStorage.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import Foundation

class MockStorage: Storage {
    var mockPerform: ((Instruction) -> ExecutionLog?)?
    func perform(instruction: Instruction) -> ExecutionLog? {
        return mockPerform?(instruction)
    }
    
    var mockReset: (() -> Void)?
    func reset() {
        mockReset?()
    }
    
    init() {}
}
