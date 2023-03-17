//
//  ProgramView.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import SwiftUI
import PreviewSnapshots

struct ProgramView: View {
    @ObservedObject var devEnvironment: DevelopmentEnviroment
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(Array(devEnvironment.program.commands.enumerated()), id: \.offset) { offset, command in
                        VStack(alignment: .leading) {
                            CommandView(command: command)
                            VStack {
                                if let log = devEnvironment.logs[command.id] {
                                    ExecutionLogView(log: log)
                                }
                            }
                        }
                    }
                    .onMove(perform: devEnvironment.moveCommand(fromOffsets:toOffset:))
                    .onDelete(perform: devEnvironment.deleteCommand(atOffsets:))
                }
                
                Section("Add a command") {
                    NewInstructionView { instruction in
                        withAnimation {
                            devEnvironment.appendCommand(.init(instruction: instruction))
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        devEnvironment.run()
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    static var snapshots: PreviewSnapshots<Program> {
        PreviewSnapshots(configurations: [
            .init(name: "Empty state", state: .init(commands: [])),
            .init(name: "Sample program", state: .init(commands: [
                .init(instruction: .begin),
                .init(instruction: .set(key: "k1", value: "v1")),
                .init(instruction: .get(key: "k1")),
                .init(instruction: .get(key: "k2")),
                .init(instruction: .commit)
            ]))
        ]) { program in
            let devEnvironment = DevelopmentEnviroment(executor: ProgramExecutor(storage: InMemoryStorage()))
            devEnvironment.program = program
            return NavigationStack {
                ProgramView(devEnvironment: devEnvironment)
            }
        }
    }
    
    static var previews: some View {
        snapshots.previews.previewLayout(.sizeThatFits)
    }
}
