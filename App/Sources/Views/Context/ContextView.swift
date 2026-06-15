//
//  ContextView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ContextView: View {
    @State private var entries: [MetadataRow] = []
    @State private var showingAdd = false
    @State private var editingRow: MetadataRow? = nil

    var body: some View {
        List {
            Section {
                ForEach(entries) { row in
                    Button {
                        editingRow = row
                    } label: {
                        LabeledContent(row.key) {
                            Text(row.displayValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                .onDelete { offsets in
                    for i in offsets {
                        CrashContextRegistry.clearMetadata(entries[i].key)
                    }
                    entries.remove(atOffsets: offsets)
                }
            } header: {
                Text("Crash metadata (\(entries.count)/\(CrashContextStorage.maxMetadataEntries))")
            } footer: {
                Text("Attached to every crash report captured by CrashReportExtension.")
            }
        }
        .navigationTitle("Context")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(entries.count >= CrashContextStorage.maxMetadataEntries)
            }
        }
        .sheet(isPresented: $showingAdd) {
            MetadataEntrySheet(existing: nil) { row in
                CrashContextRegistry.setMetadata(row.key, value: row.rawValue)
                entries.removeAll { $0.key == row.key }
                entries.append(row)
            }
        }
        .sheet(item: $editingRow) { row in
            MetadataEntrySheet(existing: row) { updated in
                CrashContextRegistry.setMetadata(updated.key, value: updated.rawValue)
                if let i = entries.firstIndex(where: { $0.key == row.key }) {
                    entries[i] = updated
                }
            }
        }
    }
}

// MARK: - Row model

struct MetadataRow: Identifiable, Equatable {
    let id = UUID()
    let key: String
    let rawValue: MetadataValue

    var displayValue: String {
        switch rawValue {
        case .string(let s): return s
        case .int(let i):    return "\(i) (int)"
        }
    }

    enum MetadataValue: Equatable {
        case string(String)
        case int(Int)
    }
}

extension CrashContextRegistry {
    static func setMetadata(_ key: String, value: MetadataRow.MetadataValue) {
        switch value {
        case .string(let s): setMetadata(key, value: s)
        case .int(let i):    setMetadata(key, value: i)
        }
    }
}

// MARK: - Add/edit sheet

private struct MetadataEntrySheet: View {
    let existing: MetadataRow?
    let onSave: (MetadataRow) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var key: String
    @State private var valueType: ValueType
    @State private var stringValue: String
    @State private var intValue: String

    init(existing: MetadataRow?, onSave: @escaping (MetadataRow) -> Void) {
        self.existing = existing
        self.onSave = onSave
        switch existing?.rawValue {
        case .string(let s):
            _key = State(initialValue: existing?.key ?? "")
            _valueType = State(initialValue: .string)
            _stringValue = State(initialValue: s)
            _intValue = State(initialValue: "")
        case .int(let i):
            _key = State(initialValue: existing?.key ?? "")
            _valueType = State(initialValue: .int)
            _stringValue = State(initialValue: "")
            _intValue = State(initialValue: "\(i)")
        case nil:
            _key = State(initialValue: "")
            _valueType = State(initialValue: .string)
            _stringValue = State(initialValue: "")
            _intValue = State(initialValue: "")
        }
    }

    private enum ValueType: String, CaseIterable {
        case string = "String"
        case int = "Int"
    }

    private var isValid: Bool {
        guard !key.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        switch valueType {
        case .string: return !stringValue.isEmpty
        case .int:    return Int(intValue) != nil
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Key") {
                    TextField("e.g. ab_variant", text: $key)
                        .autocorrectionDisabled()
                        .disabled(existing != nil)
                }
                Section("Value") {
                    Picker("Type", selection: $valueType) {
                        ForEach(ValueType.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                    switch valueType {
                    case .string:
                        TextField("e.g. control", text: $stringValue)
                            .autocorrectionDisabled()
                    case .int:
                        TextField("e.g. 3", text: $intValue)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle(existing == nil ? "Add metadata" : "Edit metadata")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedKey = key.trimmingCharacters(in: .whitespaces)
                        let value: MetadataRow.MetadataValue = valueType == .int
                            ? .int(Int(intValue) ?? 0)
                            : .string(stringValue)
                        onSave(MetadataRow(key: trimmedKey, rawValue: value))
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContextView()
    }
}
