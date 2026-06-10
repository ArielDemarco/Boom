//
//  BoomApp.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

@main
struct BoomApp: App {
    #if os(iOS)
    @State private var crashManager: MetricKitManager = MetricKitManager()
    #else
    @State private var crashManager: ExtensionCrashManager = ExtensionCrashManager()
    #endif

    var body: some Scene {
        WindowGroup {
            MainView()
                .metricKitManager(crashManager)
        }
    }
}
