//
//  CrashRow.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import SwiftUI
import Boom

struct CrashRow: View {
    let crash: any Crash

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(crash.title)
                .font(.body)
            Text(crash.crashDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 100)) {
    CrashRow(crash: CrashRegistry.shared.crashes(in: .exception).randomElement()!)
}
