//
//  CrashContextStorage.swift
//  BoomApp
//
//  Created by Ariel Demarco on 12/06/2026.
//

#if !targetEnvironment(simulator)
import CrashReportExtension
import Darwin
import Foundation

struct CrashContextStorage {
    var magic: UInt64
    var sessionId: uuid_t
    var userIdLen: UInt8
    var _userPad: (UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8)
    var userIdBytes: (UInt64,UInt64,UInt64,UInt64,UInt64,UInt64,UInt64)
    var metadataCount: UInt8
    var _metaPad: (UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8)
    var metadata: (MetadataEntry, MetadataEntry, MetadataEntry, MetadataEntry,
                   MetadataEntry, MetadataEntry, MetadataEntry, MetadataEntry)
    
    static let expectedMagic: UInt64 = 0xB00B00B00B00B00B
    static let size: Int = MemoryLayout<CrashContextStorage>.size
    static let alignment: Int = MemoryLayout<CrashContextStorage>.alignment
    static let maxMetadataCount: Int = 8 // Should update on updating metadata variable def with more or less entries

    var sessionUUID: UUID { UUID(uuid: sessionId) }
    
    var userId: String? {
        guard userIdLen > 0 else { return nil }
        return withUnsafeBytes(of: userIdBytes) { buf in
            String(bytes: buf.prefix(Int(userIdLen)), encoding: .utf8)
        }
    }
    
    func entry(at index: Int) -> MetadataEntry {
        withUnsafeBytes(of: metadata) { buf in
            buf.load(fromByteOffset: index * MetadataEntry.stride, as: MetadataEntry.self)
        }
    }
}

#endif
