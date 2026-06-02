//
//  CrashListView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Boom

@MainActor
struct CrashListView: View {
    @State private var selectedCrash: (any Crash)?
    @State private var showConfirmation = false
    @State private var scheduledCrash: (any Crash)? = CrashRegistry.shared.scheduledStartupCrash

    private var grouped: [(CrashCategory, [any Crash])] {
        CrashCategory.allCases.compactMap { category in
            let items = CrashRegistry.shared.crashes(in: category)
            return items.isEmpty ? nil : (category, items)
        }
    }

    var body: some View {
        List {
            if let scheduled = scheduledCrash {
                scheduledBanner(for: scheduled)
            }
            ForEach(grouped, id: \.0) { category, crashes in
                Section(category.rawValue) {
                    ForEach(crashes, id: \.title) { crash in
                        CrashRow(crash: crash)
                            .onTapGesture {
                                selectedCrash = crash
                                showConfirmation = true
                            }
                    }
                }
            }
        }
        .confirmationDialog(
            confirmationTitle,
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Trigger crash", role: .destructive) {
                selectedCrash?.trigger()
            }
            Button("Schedule on next launch") {
                if let crash = selectedCrash {
                    CrashRegistry.shared.scheduleStartupCrash(crash)
                    scheduledCrash = crash
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let crash = selectedCrash {
                Text(crash.crashDescription)
            }
        }
    }

    private var confirmationTitle: String {
        selectedCrash.map { "Trigger: \($0.title)" } ?? ""
    }

    @ViewBuilder
    private func scheduledBanner(for crash: any Crash) -> some View {
        Section {
            HStack {
                Label(crash.title, systemImage: "clock.badge.exclamationmark")
                    .font(.subheadline)
                Spacer()
                Button("Cancel") {
                    CrashRegistry.shared.cancelScheduledStartupCrash()
                    scheduledCrash = nil
                }
                .font(.subheadline)
                .tint(.red)
            }
        } header: {
            Text("Scheduled on next launch")
        }
    }
}

#Preview {
    CrashListView()
}
