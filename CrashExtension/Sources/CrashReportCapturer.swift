//
//  CrashReportCapturer.swift
//  BoomCrashExtension
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if !targetEnvironment(simulator)
// CrashReportExtension is unavailable in the simulator SDK in Xcode 27.0 beta (27A5194q) (Feedback FB23019442)
import CrashReportExtension
import Foundation

struct CrashReportCapturer {
    let process: CrashedProcess

    func captureAndSave() {
        let payload = ExtensionCrashPayload(
            capturedAt: Date().timeIntervalSince1970,
            reason: .init(
                exception: process.reason.exception,
                codes: process.reason.codes
            ),
            binaryImages: process.binaryImages.map {
                .init(
                    path: $0.path,
                    uuid: $0.uuid?.uuidString,
                    baseAddress: "0x\(String($0.baseAddress, radix: 16))",
                    size: $0.size
                )
            },
            corpsePort: process.corpsePort,
            osVersion: osVersionString,
            deviceType: hardwareModel,
            architecture: cpuArchitecture,
            appVersion: bundleVersion
        )
        ExtensionCrashStorage().save(payload, exception: Int(process.reason.exception))
    }

    private var bundleVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    private var osVersionString: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    private var hardwareModel: String {
        var info = utsname()
        uname(&info)
        return withUnsafePointer(to: info.machine) { tuplePtr in
            tuplePtr.withMemoryRebound(
                to: CChar.self,
                capacity: MemoryLayout.size(ofValue: info.machine)
            ) { String(cString: $0) }
        }
    }

    private var cpuArchitecture: String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "unknown"
        #endif
    }
}
#endif
