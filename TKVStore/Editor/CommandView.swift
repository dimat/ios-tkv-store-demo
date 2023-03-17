//
//  CommandView.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import SwiftUI
import PreviewSnapshots

struct CommandView: View {
    let command: Command
    
    var body: some View {
        HStack {
            Text(command.instruction.operation.title)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .font(.caption)
                .background(Capsule().foregroundColor(Color.accentColor.opacity(0.5)))
            
            switch command.instruction {
            case .set(let key, let value):
                (Text("K: ").bold() + Text(key)).font(.caption)
                (Text("V: ").bold() + Text(value)).font(.caption)
            case .get(let key):
                (Text("K: ").bold() + Text(key)).font(.caption)
            case .delete(let key):
                (Text("K: ").bold() + Text(key)).font(.caption)
            case .count(let value):
                (Text("V: ").bold() + Text(value)).font(.caption)
            case .begin, .commit, .rollback: EmptyView()
            }
            
        }
    }
}

struct CommandView_Previews: PreviewProvider {
    static var previews: some View {
        snapshots.previews.previewLayout(.sizeThatFits)
    }
    
    static var snapshots: PreviewSnapshots<Void> {
        PreviewSnapshots(configurations: [
            .init(name: "Combined", state: Void())
        ]) { _ in
            VStack(alignment: .leading) {
                CommandView(command: .init(instruction: .commit))
                CommandView(command: .init(instruction: .set(key: "k1", value: "v1")))
                CommandView(command: .init(instruction: .get(key: "k1")))
                CommandView(command: .init(instruction: .delete(key: "k1")))
                CommandView(command: .init(instruction: .count(value: "v1")))
            }
            .padding()
        }
    }
}
