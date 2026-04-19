//
//  CrashReportsView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)
import SwiftUI

struct CrashReportsView: View {
    @Environment(\.metricKitManager) private var manager: any MetricKitManaging
    @State private var selected: CrashReportSummary?

    var body: some View {
        Group {
            if manager.summaries.isEmpty {
                ContentUnavailableView(
                    "No crash reports",
                    systemImage: "checkmark.shield",
                    description: Text("MetricKit delivers reports from the previous session on next launch. Crashes on Simulator are not captured.")
                )
            } else {
                List {
                    ForEach(manager.summaries) { summary in
                        CrashReportRow(summary: summary)
                            .onTapGesture {
                                manager.markAsRead(summary)
                                selected = summary
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.map { manager.summaries[$0] }.forEach { manager.delete($0) }
                    }
                }
            }
        }
        .navigationTitle("Crash Reports")
        .toolbar {
            if !manager.summaries.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear all", role: .destructive) {
                        manager.deleteAll()
                    }
                }
            }
        }
        .sheet(item: $selected) { summary in
            CrashReportDetailView(summary: summary)
        }
    }
}

#Preview {
    CrashReportsView()
}
#endif
