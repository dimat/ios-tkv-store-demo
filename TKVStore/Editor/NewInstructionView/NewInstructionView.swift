//
//  NewInstructionView.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import SwiftUI
import PreviewSnapshots

struct NewInstructionView: View {
    typealias Configuration = (NewInstructionViewModel) -> Void
    @StateObject private var viewModel: NewInstructionViewModel
    
    init(onSubmit: @escaping (Instruction) -> Void, configuration: Configuration? = nil) {
        _viewModel = .init(wrappedValue: {
            let viewModel = NewInstructionViewModel(onSubmit: onSubmit)
            configuration?(viewModel)
            return viewModel
        }())
    }
    
    var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading) {
                Picker("Operation", selection: $viewModel.operation) {
                    ForEach(Operation.allCases, id: \.self) { operation in
                        Text(operation.title)
                            .tag(operation)
                    }
                    
                }
                .labelsHidden()
                
                if viewModel.isKeyVisible {
                    TextField("Key", text: $viewModel.key)
                }
                
                if viewModel.isValueVisible {
                    TextField("Value", text: $viewModel.value)
                }
            }
            
            Spacer()
            
            Button {
                viewModel.didTapAdd()
            } label: {
                Text("Add")
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(!viewModel.isValid)
        }
    }
}

struct NewInstructionView_Previews: PreviewProvider {
    static var previews: some View {
        snapshots.previews.previewLayout(.sizeThatFits)
    }
    
    static var snapshots: PreviewSnapshots<NewInstructionView.Configuration> {
        PreviewSnapshots(configurations: [
            .init(name: "Default", state: { _ in }),
            .init(name: "Valid", state: {
                $0.key = "key"
                $0.value = "value"
            }),
            .init(name: "Begin", state: {
                $0.operation = .begin
            })
        ]) { configuration in
            List {
                NewInstructionView(onSubmit: { _ in }, configuration: configuration)
            }
        }
    }
}
