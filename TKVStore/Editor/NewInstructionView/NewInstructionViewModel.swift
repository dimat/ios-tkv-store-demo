//
//  NewInstructionViewModel.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import Combine

class NewInstructionViewModel: ObservableObject {
    @Published var operation: Operation = .set
    @Published var key: String = ""
    @Published var value: String = ""
    
    private var onSubmit: (Instruction) -> Void
    
    init(onSubmit: @escaping (Instruction) -> Void) {
        self.onSubmit = onSubmit
    }
    
    var isValid: Bool {
        switch operation {
        case .set: return !key.isEmpty && !value.isEmpty
        case .get: return !key.isEmpty
        case .delete: return !key.isEmpty
        case .count: return !value.isEmpty
        case .begin, .commit, .rollback: return true
        }
    }
    
    var isKeyVisible: Bool {
        switch operation {
        case .set, .get, .delete: return true
        default: return false
        }
    }
    
    var isValueVisible: Bool {
        switch operation {
        case .set, .count: return true
        default: return false
        }
    }
    
    func didTapAdd() {
        guard isValid else {
            return
        }
        switch operation {
        case .set: onSubmit(.set(key: key, value: value))
        case .get: onSubmit(.get(key: key))
        case .delete: onSubmit(.delete(key: key))
        case .count: onSubmit(.count(value: value))
        case .begin: onSubmit(.begin)
        case .commit: onSubmit(.commit)
        case .rollback: onSubmit(.rollback)
        }
    }
}
