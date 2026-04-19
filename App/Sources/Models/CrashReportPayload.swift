//
//  CrashReportPayload.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct CrashReportPayload: Codable {
    let sessionStart: Date
    let sessionEnd: Date
    let applicationVersion: String
    let signal: Int?
    let exceptionType: Int?
    let exceptionCode: Int?
    let virtualMemoryRegionInfo: String?
    let terminationReason: String?
    let osVersion: String
    let deviceType: String
    let platformArchitecture: String
    let callStackJSON: String
    
    var exceptionTypeDisplay: String? {
        guard let type_ = exceptionType else { return nil }
        let name: String? = switch type_ {
        case 1:  "EXC_BAD_ACCESS"
        case 2:  "EXC_BAD_INSTRUCTION"
        case 3:  "EXC_ARITHMETIC"
        case 5:  "EXC_SOFTWARE"
        case 6:  "EXC_BREAKPOINT"
        case 10: "EXC_CRASH"
        case 11: "EXC_RESOURCE"
        case 12: "EXC_GUARD"
        default: nil
        }
        return name.map { "\($0) (\(type_))" } ?? "0x\(String(type_, radix: 16, uppercase: true))"
    }
    
    var exceptionCodeDisplay: String? {
        guard let code = exceptionCode else { return nil }
        return "0x\(String(UInt(bitPattern: code), radix: 16, uppercase: true))"
    }
}

