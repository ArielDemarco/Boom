//
//  ContentView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Boom

struct MainView: View {
    var body: some View {
        TabView {
            Tab("Crashes", systemImage: "bolt.fill") {
                NavigationStack {
                    CrashListView()
                        .navigationTitle("Boom")
                }
            }
            Tab("Reports", systemImage: "doc.text.magnifyingglass") {
                NavigationStack {
                    CrashReportsView()
                }
            }
        }
    }
}

#Preview {
    MainView()
}
