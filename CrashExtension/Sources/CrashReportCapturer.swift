//
//  CrashReportCapturer.swift
//  BoomCrashExtension
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if !targetEnvironment(simulator)
import CrashReportExtension
import Darwin
import Foundation
import os

private let log = Logger(subsystem: "com.ademarco.boomapp.crash-extension", category: "StackWalk")

// C macros not importable in Swift so we generate them computed manually
private let kARM_THREAD_STATE64_COUNT = mach_msg_type_number_t(
    MemoryLayout<arm_thread_state64_t>.size / MemoryLayout<UInt32>.size
)
private let kTHREAD_EXTENDED_INFO_FLAVOR = thread_flavor_t(5)
private let kTHREAD_EXTENDED_INFO_COUNT = mach_msg_type_number_t(
    MemoryLayout<thread_extended_info>.size / MemoryLayout<integer_t>.size
)

struct CrashReportCapturer: @unchecked Sendable {
    let process: CrashedProcess

    func captureAndSave() async {
        var threads: [ThreadCapture] = []
        do {
            threads = try await walkStack()
            log.info("Stack walk captured \(threads.count) thread(s)")
        } catch {
            log.warning("Stack walk failed: \(error)")
        }

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
            threads: threads,
            osVersion: osVersionString,
            deviceType: hardwareModel,
            architecture: cpuArchitecture,
            appVersion: bundleVersion
        )
        ExtensionCrashStorage().save(payload, exception: Int(process.reason.exception))
    }

    // MARK: - Stack walk

    func walkStack() async throws -> [ThreadCapture] {
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0

        guard task_threads(process.corpsePort, &threadList, &threadCount) == KERN_SUCCESS,
              let threads = threadList else { return [] }

        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: threadList),
                vm_size_t(Int(threadCount) * MemoryLayout<thread_act_t>.size)
            )
        }

        var result = [ThreadCapture]()
        for i in 0..<Int(threadCount) {
            let addresses = threadAddresses(threads[i])
            guard !addresses.isEmpty else { continue }
            let groups = process.symbolicateAddresses(addresses)
            result.append(ThreadCapture(
                name: threadName(threads[i]),
                frameGroups: groups,
                frameAddresses: addresses
            ))
        }
        return result
    }

    // MARK: - Per-thread address collection

    private func threadAddresses(_ thread: thread_act_t) -> [UInt64] {
#if arch(arm64)
        var state = arm_thread_state64_t()
        var count = kARM_THREAD_STATE64_COUNT

        let kr = withUnsafeMutablePointer(to: &state) { ptr in
            ptr.withMemoryRebound(to: UInt32.self, capacity: Int(kARM_THREAD_STATE64_COUNT)) {
                thread_get_state(thread, ARM_THREAD_STATE64, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return [] }

        var addresses = [UInt64]()
        let pc: UInt64 = stripPAC(state.__pc)
        if pc > 0 { addresses.append(pc) }

        var fp: UInt64 = stripPAC(state.__fp)
        for _ in 0..<64 {
            guard fp > 0 else { break }

            // Tuple is contiguous; reads [prev_fp (8 bytes), return_addr (8 bytes)]
            var frame: (UInt64, UInt64) = (0, 0)
            var bytesRead = vm_size_t(0)
            let ok = withUnsafeMutableBytes(of: &frame) { buf in
                vm_read_overwrite(
                    process.corpsePort,
                    vm_address_t(fp),
                    vm_size_t(16),
                    vm_address_t(bitPattern: buf.baseAddress!),
                    &bytesRead
                ) == KERN_SUCCESS && bytesRead == vm_size_t(16)
            }
            guard ok else { break }

            let ret: UInt64 = stripPAC(frame.1)
            if ret > 4 { addresses.append(ret - 4) }

            let nextFP: UInt64 = stripPAC(frame.0)
            guard nextFP != fp else { break }
            fp = nextFP
        }

        return addresses
#else
        return []
#endif
    }

    private func threadName(_ thread: thread_act_t) -> String? {
        var info = thread_extended_info()
        var count = kTHREAD_EXTENDED_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(kTHREAD_EXTENDED_INFO_COUNT)) {
                thread_info(thread, kTHREAD_EXTENDED_INFO_FLAVOR, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return nil }
        let name = withUnsafePointer(to: info.pth_name) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: info.pth_name)) {
                String(cString: $0)
            }
        }
        return name.isEmpty ? nil : name
    }

    private func stripPAC(_ addr: UInt64) -> UInt64 {
        addr & 0x0007ffffffffffff
    }

    // MARK: - System info

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
        return withUnsafePointer(to: info.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: info.machine)) {
                String(cString: $0)
            }
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
