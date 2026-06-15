//
//  CrashMetadataEntry.swift
//  BoomApp
//
//  Created by Ariel Demarco on 12/06/2026.
//

#if !targetEnvironment(simulator)
import CrashReportExtension
import Darwin
import Foundation

// MARK: - Mirror structs
// Layout MUST stay in sync with App/Sources/Models/CrashContext.swift.
struct MetadataEntry {
    var keyLen: UInt8
    var valueType: UInt8
    var valueLen: UInt8
    var _pad: (UInt8, UInt8, UInt8, UInt8, UInt8)
    var keyBytes: (UInt64, UInt64)
    var valueBytes: (UInt64, UInt64, UInt64, UInt64)
    
    static let stride: Int = MemoryLayout<MetadataEntry>.stride

    var key: String {
        guard keyLen > 0 else { return "" }
        return withUnsafeBytes(of: keyBytes) { buf in
            String(bytes: buf.prefix(Int(keyLen)), encoding: .utf8) ?? ""
        }
    }
    
    var stringValue: String? {
        guard valueType == 1, valueLen > 0 else { return nil }
        return withUnsafeBytes(of: valueBytes) { buf in
            String(bytes: buf.prefix(Int(valueLen)), encoding: .utf8)
        }
    }
    
    var intValue: Int64? {
        guard valueType == 2 else { return nil }
        return withUnsafeBytes(of: valueBytes) { buf in buf.load(as: Int64.self) }
    }
}

#endif
