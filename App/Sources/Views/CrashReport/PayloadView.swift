//
//  CrashReportsView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)
import SwiftUI

struct PayloadView: View {
    let summary: CrashReportSummary
    let payload: CrashReportPayload

    var body: some View {
        List {
            Section("Crash") {
                LabeledContent("Signal", value: summary.signalName)
                if let display = payload.exceptionTypeDisplay {
                    LabeledContent("Exception type", value: display)
                }
                if let display = payload.exceptionCodeDisplay {
                    LabeledContent("Exception code", value: display)
                }
                if let vmInfo = payload.virtualMemoryRegionInfo {
                    LabeledContent("VM region", value: vmInfo)
                }
                if let reason = payload.terminationReason {
                    LabeledContent("Termination reason", value: reason)
                }
            }

            Section("Session") {
                LabeledContent("Start", value: payload.sessionStart.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("End", value: payload.sessionEnd.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("App version", value: payload.applicationVersion)
            }

            Section("Device") {
                LabeledContent("OS", value: payload.osVersion)
                LabeledContent("Device", value: payload.deviceType)
                LabeledContent("Architecture", value: payload.platformArchitecture)
            }

            Section("Call Stack") {
                NavigationLink("View full stack") {
                    CallStackView(json: payload.callStackJSON)
                }
            }
        }
    }
}

#Preview {
    PayloadView(
        summary: .init(
            id: .init(),
            date: .now,
            signal: 8,
            exceptionType: 10,
            isRead: true
        ), payload: .init(
            sessionStart: .now,
            sessionEnd: .now,
            applicationVersion: "1.1.1",
            signal: 8,
            exceptionType: 10,
            exceptionCode: 10,
            virtualMemoryRegionInfo: "0x01",
            terminationReason: "Broken stuff",
            osVersion: "18.1.2",
            deviceType: "This one",
            platformArchitecture: "x86_64",
            callStackJSON: Thread.callStackSymbols.joined(separator: "\n")
        )
    )
}
#endif
