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

    private var grouped: [(CrashCategory, [any Crash])] {
        CrashCategory.allCases.compactMap { category in
            let items = CrashRegistry.shared.crashes(in: category)
            return items.isEmpty ? nil : (category, items)
        }
    }

    var body: some View {
        List {
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
}

#Preview {
    CrashListView()
}
