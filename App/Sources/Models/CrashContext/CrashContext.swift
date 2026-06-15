//
//  CrashContext.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Darwin
import Foundation
import MachO

// MARK: - MetadataEntry
//
// Fixed-size slot for one key-value pair.
// Layout (56 bytes, align 8):
//   +0   keyLen      UInt8
//   +1   valueType   UInt8  (0=empty, 1=string, 2=int64)
//   +2   valueLen    UInt8  (string only)
//   +3   _pad        UInt8 x 5  → reaches +8
//   +8   keyBytes    UInt64 x 2  (16 bytes, UTF-8 key)
//   +24  valueBytes  UInt64 x 4  (32 bytes: UTF-8 string OR Int64 in first 8)
struct MetadataEntry {
    var keyLen: UInt8
    var valueType: UInt8
    var valueLen: UInt8
    var _pad: (UInt8, UInt8, UInt8, UInt8, UInt8)
    var keyBytes: (UInt64, UInt64)
    var valueBytes: (UInt64, UInt64, UInt64, UInt64)

    static let stride: Int = MemoryLayout<MetadataEntry>.stride
    
    static let empty = MetadataEntry(
        keyLen: 0,
        valueType: 0,
        valueLen: 0,
        _pad: (0,0,0,0,0),
        keyBytes: (0,0),
        valueBytes: (0,0,0,0)
    )

    var isEmpty: Bool { valueType == 0 }

    var key: String {
        guard keyLen > 0 else { return "" }
        return withUnsafeBytes(of: keyBytes) { buf in
            String(bytes: buf.prefix(Int(keyLen)), encoding: .utf8) ?? ""
        }
    }

    mutating func setKey(_ string: String) {
        let bytes = Array(string.utf8.prefix(16))
        keyLen = UInt8(bytes.count)
        withUnsafeMutableBytes(of: &keyBytes) { buf in
            for (i, b) in bytes.enumerated() { buf[i] = b }
        }
    }

    var stringValue: String? {
        guard valueType == 1, valueLen > 0 else { return nil }
        return withUnsafeBytes(of: valueBytes) { buf in
            String(bytes: buf.prefix(Int(valueLen)), encoding: .utf8)
        }
    }

    mutating func set(string: String) {
        let bytes = Array(string.utf8.prefix(32))
        valueType = 1
        valueLen = UInt8(bytes.count)
        withUnsafeMutableBytes(of: &valueBytes) { buf in
            for (i, b) in bytes.enumerated() { buf[i] = b }
        }
    }

    var intValue: Int64? {
        guard valueType == 2 else { return nil }
        return withUnsafeBytes(of: valueBytes) { buf in
            buf.load(as: Int64.self)
        }
    }

    mutating func set(int: Int) {
        valueType = 2
        valueLen = 0
        let v = Int64(int)
        withUnsafeMutableBytes(of: &valueBytes) { buf in
            buf.storeBytes(of: v, as: Int64.self)
        }
    }
}
