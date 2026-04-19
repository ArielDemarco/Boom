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
    @State private var metricKit: MetricKitManager = MetricKitManager()
    #endif

    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            MainView()
                .metricKitManager(metricKit)
            #else
            MainView()
            #endif
        }
    }
}
