//
//  ContentView.swift
//  TKVStore
//
//  Created by Dmitry Matyukhin on 17/03/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var devEnvironment = DevelopmentEnviroment(executor: ProgramExecutor(storage: InMemoryStorage()))
    @State var isEditorPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    link(title: "Blank", instructions: [])
                }
                
                Section("Samples") {
                    
                    
                    link(title: "Set and get a value", instructions: [
                        .set(key: "foo", value: "123"),
                        .get(key: "foo")
                    ])
                    
                    link(title: "Delete a value", instructions: [
                        .delete(key: "foo"),
                        .get(key: "foo")
                    ])
                    
                    link(title: "Count the number of occurrences of a value", instructions: [
                        .set(key: "foo", value: "123"),
                        .set(key: "bar", value: "456"),
                        .set(key: "baz", value: "123"),
                        .count(value: "123"),
                        .count(value: "456")
                    ])
                    
                    link(title: "Commit a transaction", instructions: [
                        .set(key: "bar", value: "123"),
                        .get(key: "bar"),
                        .begin,
                        .set(key: "foo", value: "456"),
                        .get(key: "bar"),
                        .delete(key: "bar"),
                        .commit,
                        .get(key: "bar"),
                        .rollback,
                        .get(key: "foo")
                    ])
                    
                    link(title: "Rollback a transaction", instructions: [
                        .set(key: "foo", value: "123"),
                        .set(key: "bar", value: "abc"),
                        .begin,
                        .set(key: "foo", value: "456"),
                        .get(key: "foo"),
                        .set(key: "bar", value: "def"),
                        .get(key: "bar"),
                        .rollback,
                        .get(key: "foo"),
                        .get(key: "bar"),
                        .commit
                    ])
                    
                    link(title: "Nested transactions", instructions: [
                        .set(key: "foo", value: "123"),
                        .set(key: "bar", value: "456"),
                        .begin,
                        .set(key: "foo", value: "456"),
                        .begin,
                        .count(value: "456"),
                        .get(key: "foo"),
                        .set(key: "foo", value: "789"),
                        .get(key: "foo"),
                        .rollback,
                        .get(key: "foo"),
                        .delete(key: "foo"),
                        .get(key: "foo"),
                        .rollback,
                        .get(key: "foo")
                    ])
                }
            }
            .navigationDestination(isPresented: $isEditorPresented) {
                ProgramView(devEnvironment: devEnvironment)
            }
        }
    }
    
    @ViewBuilder
    private func link(title: String, instructions: [Instruction]) -> some View {
        Button {
            devEnvironment.program = .init(commands: instructions.map { Command(instruction: $0) } )
            isEditorPresented = true
        } label: {
            Text(title)
        }
        .buttonStyle(.plain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
