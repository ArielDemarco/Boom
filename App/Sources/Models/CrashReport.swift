//
//  CrashReport.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

// MARK: - Source

enum ReportSource: String {
    case metricKit = "mk"
    case crashExtension = "ext"
    case unknown = "unk"

    var label: String {
        switch self {
        case .metricKit:       "MetricKit"
        case .crashExtension:  "CrashExt"
        case .unknown:         "Unknown"
        }
    }
}

// MARK: - Summary (derived from filename, no file reads for the list)

struct CrashReportSummary: Identifiable {
    let id: UUID
    let date: Date
    let signal: Int?
    let exceptionType: Int?
    let source: ReportSource
    var isRead: Bool
    let filename: String

    init(
        id: UUID,
        date: Date,
        signal: Int?,
        exceptionType: Int?,
        isRead: Bool,
        source: ReportSource = .unknown
    ) {
        self.id = id
        self.date = date
        self.signal = signal
        self.exceptionType = exceptionType
        self.source = source
        self.isRead = isRead
        let sig = signal.map(String.init) ?? "nil"
        let exc = exceptionType.map(String.init) ?? "nil"
        self.filename = "\(source.rawValue)_\(id.uuidString)_\(Int(date.timeIntervalSince1970 * 1000))_\(sig)_\(exc).json"
    }

    // Parses both new format (source_UUID_epochMs_signal_exc.json)
    // and legacy format (UUID_epochMs_signal_exc.json).
    init?(filename: String, isRead: Bool) {
        let name = filename.replacingOccurrences(of: ".json", with: "")

        // Try new format first (5 parts with source prefix)
        let parts5 = name.split(separator: "_", maxSplits: 4)
        if parts5.count == 5,
           let src = ReportSource(rawValue: String(parts5[0])),
           let id = UUID(uuidString: String(parts5[1])),
           let epochMs = Int(parts5[2]) {
            self.id = id
            self.date = Date(timeIntervalSince1970: TimeInterval(epochMs) / 1000)
            self.signal = Int(parts5[3])
            self.exceptionType = Int(parts5[4])
            self.source = src
            self.isRead = isRead
            self.filename = filename
            return
        }

        // Legacy format (no source prefix)
        let parts4 = name.split(separator: "_", maxSplits: 3)
        guard parts4.count == 4,
              let id = UUID(uuidString: String(parts4[0])),
              let epochMs = Int(parts4[1]) else { return nil }
        self.id = id
        self.date = Date(timeIntervalSince1970: TimeInterval(epochMs) / 1000)
        self.signal = Int(parts4[2])
        self.exceptionType = Int(parts4[3])
        self.source = .unknown
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
