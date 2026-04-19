//
//  MetricKitManagerEnvironment.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

private struct MetricKitManagerKey: EnvironmentKey {
    static let defaultValue: any MetricKitManaging = NoopMetricKitManager()
}

extension EnvironmentValues {
    var metricKitManager: any MetricKitManaging {
        get { self[MetricKitManagerKey.self] }
        set { self[MetricKitManagerKey.self] = newValue }
    }
}

extension View {
    func metricKitManager(_ manager: any MetricKitManaging) -> some View {
        environment(\.metricKitManager, manager)
    }
}
