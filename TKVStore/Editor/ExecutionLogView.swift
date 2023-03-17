//
//  LogView.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import SwiftUI
import PreviewSnapshots

struct ExecutionLogView: View {
    let log: ExecutionLog
    
    var body: some View {
        switch log {
        case .warning(let message): warning(message: message)
        case .output(let value): output(value: value)
        }
    }
    
    func warning(message: String) -> some View {
        Text("\(Image(systemName: "exclamationmark.triangle.fill")) \(message)")
            .font(.caption)
            .foregroundColor(.red)
    }
    
    func output(value: String) -> some View {
        Text(value)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}


struct ExecutionLogView_Previews: PreviewProvider {
    static var previews: some View {
        snapshots.previews.previewLayout(.sizeThatFits)
    }
    
    static var snapshots: PreviewSnapshots<Void> {
        PreviewSnapshots(configurations: [
            .init(name: "Combined", state: Void())
        ]) { _ in
            VStack(alignment: .leading) {
                ExecutionLogView(log: .output("some value"))
                ExecutionLogView(log: .warning("key doesn't exist"))
            }
        }
    }
}
