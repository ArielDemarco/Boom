//
//  CrashReport.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - Summary (derived from filename, no file reads for the list)

struct CrashReportSummary: Identifiable {
    let id: UUID
    let date: Date
    let signal: Int?
    let exceptionType: Int?
    var isRead: Bool
    // Stored so file operations always use the exact name from dis
    let filename: String

    init(
        id: UUID,
        date: Date,
        signal: Int?,
        exceptionType: Int?,
        isRead: Bool
    ) {
        self.id = id
        self.date = date
        self.signal = signal
        self.exceptionType = exceptionType
        self.isRead = isRead
        let sig = signal.map(String.init) ?? "nil"
        let exc = exceptionType.map(String.init) ?? "nil"
        self.filename = "\(id.uuidString)_\(Int(date.timeIntervalSince1970 * 1000))_\(sig)_\(exc).json"
    }

    init?(
        filename: String,
        isRead: Bool
    ) {
        let name = filename.replacingOccurrences(of: ".json", with: "")
        let parts = name.split(separator: "_", maxSplits: 3)
        guard parts.count == 4,
              let id = UUID(uuidString: String(parts[0])),
              let epochMs = Int(parts[1]) else { return nil }

        self.id = id
        self.date = Date(timeIntervalSince1970: TimeInterval(epochMs) / 1000)
        self.signal = Int(parts[2])
        self.exceptionType = Int(parts[3])
        self.isRead = isRead
        self.filename = filename
    }

    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    var signalName: String {
        guard let signal else { return "Unknown" }
        return switch signal {
        case 4:  "SIGILL"
        case 5:  "SIGTRAP"
        case 6:  "SIGABRT"
        case 7:  "SIGBUS"
        case 8:  "SIGFPE"
        case 11: "SIGSEGV"
        default: "SIG(\(signal))"
        }
    }

    var exceptionTypeName: String? {
        guard let type_ = exceptionType else { return nil }
        return switch type_ {
        case 1:  "EXC_BAD_ACCESS"
        case 2:  "EXC_BAD_INSTRUCTION"
        case 3:  "EXC_ARITHMETIC"
        case 4:  "EXC_EMULATION"
        case 5:  "EXC_SOFTWARE"
        case 6:  "EXC_BREAKPOINT"
        case 7:  "EXC_SYSCALL"
        case 8:  "EXC_MACH_SYSCALL"
        case 9:  "EXC_RPC_ALERT"
        case 10: "EXC_CRASH"
        case 11: "EXC_RESOURCE"
        case 12: "EXC_GUARD"
        case 13: "EXC_CORPSE_NOTIFY"
        default: nil
        }
    }
}
