//
//  CrashReportsView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CrashReportRow: View {
    let summary: CrashReportSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(summary.signalName)
                        .font(.headline)
                    if let typeName = summary.exceptionTypeName {
                        Text(typeName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(summary.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !summary.isRead {
                Image(systemName: "circle.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 100)) {
    CrashReportRow(summary: .init(id: .init(), date: .now, signal: 8, exceptionType: 10, isRead: true))
    Spacer()
    CrashReportRow(summary: .init(id: .init(), date: .now, signal: 7, exceptionType: 11, isRead: false))
}
