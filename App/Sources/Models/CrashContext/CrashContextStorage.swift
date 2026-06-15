//
//  CrashContextStorage.swift
//  BoomApp
//
//  Created by Ariel Demarco on 12/06/2026.
//

import Foundation

// MARK: - CrashContextStorage
//
// Fixed-size struct that lives in a static global so the extension can read it
// from the corpse port after a crash. All fields are value types — no heap pointers.
//
// IMPORTANT: Keep layout in sync with CrashExtension/Sources/CrashContextReader.swift.
// Layout (544 bytes, align 8):
//   +0    magic          UInt64         (8)
//   +8    sessionId      uuid_t         (16)
//   +24   userIdLen      UInt8          (1)
//   +25   _userPad       UInt8 x 7      (7)   → +32
//   +32   userIdBytes    UInt64 x 7     (56)  → +88
//   +88   metadataCount  UInt8          (1)
//   +89   _metaPad       UInt8 x 7      (7)   → +96
//   +96   metadata       MetadataEntry x 8   (448) → +544
struct CrashContextStorage {
    static let expectedMagic: UInt64 = 0xB00B00B00B00B00B
    static let maxMetadataEntries = 8

    var magic: UInt64 = CrashContextStorage.expectedMagic
    var sessionId: uuid_t = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    var userIdLen: UInt8 = 0
    var _userPad: (UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8) = (0,0,0,0,0,0,0)
    var userIdBytes: (UInt64,UInt64,UInt64,UInt64,UInt64,UInt64,UInt64) = (0,0,0,0,0,0,0)
    var metadataCount: UInt8 = 0
    var _metaPad: (UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8) = (0,0,0,0,0,0,0)
    var metadata: (MetadataEntry, MetadataEntry, MetadataEntry, MetadataEntry,
                   MetadataEntry, MetadataEntry, MetadataEntry, MetadataEntry) = (
        .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty
    )

    // MARK: Session / User

    mutating func set(sessionId id: UUID) { sessionId = id.uuid }
    var sessionUUID: UUID { UUID(uuid: sessionId) }

    mutating func set(userId: String?) {
        guard let userId, !userId.isEmpty else { userIdLen = 0; return }
        let bytes = Array(userId.utf8.prefix(56))
        userIdLen = UInt8(bytes.count)
        withUnsafeMutableBytes(of: &userIdBytes) { buf in
            for (i, b) in bytes.enumerated() { buf[i] = b }
        }
    }

    var userId: String? {
        guard userIdLen > 0 else { return nil }
        return withUnsafeBytes(of: userIdBytes) { buf in
            String(bytes: buf.prefix(Int(userIdLen)), encoding: .utf8)
        }
    }

    // MARK: Metadata (by-index access via unsafe bytes)

    func entry(at index: Int) -> MetadataEntry {
        withUnsafeBytes(of: metadata) { buf in
            buf.load(fromByteOffset: index * MetadataEntry.stride, as: MetadataEntry.self)
        }
    }

    mutating func setEntry(_ entry: MetadataEntry, at index: Int) {
        withUnsafeMutableBytes(of: &metadata) { buf in
            buf.storeBytes(of: entry, toByteOffset: index * MetadataEntry.stride, as: MetadataEntry.self)
        }
    }

    mutating func indexForKey(_ key: String) -> Int? {
        let n = Int(metadataCount)
        for i in 0..<min(n, CrashContextStorage.maxMetadataEntries) {
            if entry(at: i).key == key { return i }
        }
        return nil
    }

    mutating func set(string value: String, forKey key: String) {
        let idx = indexForKey(key) ?? nextEmptySlot()
        guard let i = idx else { return }
        var e = MetadataEntry.empty
        e.setKey(key)
        e.set(string: value)
        setEntry(e, at: i)
        if Int(metadataCount) <= i { metadataCount = UInt8(i + 1) }
    }

    mutating func set(int value: Int, forKey key: String) {
        let idx = indexForKey(key) ?? nextEmptySlot()
        guard let i = idx else { return }
        var e = MetadataEntry.empty
        e.setKey(key)
        e.set(int: value)
        setEntry(e, at: i)
        if Int(metadataCount) <= i { metadataCount = UInt8(i + 1) }
    }

    mutating func clear(key: String) {
        guard let i = indexForKey(key) else { return }
        setEntry(.empty, at: i)
        // compact: shift remaining entries down
        let n = Int(metadataCount)
        for j in (i+1)..<n {
            setEntry(entry(at: j), at: j - 1)
            setEntry(.empty, at: j)
        }
        if metadataCount > 0 { metadataCount -= 1 }
    }

    private func nextEmptySlot() -> Int? {
        let n = min(Int(metadataCount), CrashContextStorage.maxMetadataEntries)
        if n < CrashContextStorage.maxMetadataEntries { return n }
        // all slots used; see if any is empty (from a clear)
        for i in 0..<CrashContextStorage.maxMetadataEntries {
            if entry(at: i).isEmpty { return i }
        }
        return nil
    }
}
