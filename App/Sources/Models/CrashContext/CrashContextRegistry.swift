//
//  CrashContextRegistry.swift
//  BoomApp
//
//  Created by Ariel Demarco on 12/06/2026.
//

import Darwin
import Foundation
import MachO

enum CrashContextRegistry {
    enum Constants {
        static let appGroupID = "group.com.ademarco.boomapp"
        static let ctxOffsetKey = "sdk.ctx_offset"
        static let ctxUUIDKey   = "sdk.ctx_uuid"
    }
    
    nonisolated(unsafe) static var storage = CrashContextStorage()
    
    static func register() {
        withUnsafePointer(to: &storage) { ptr in
            var info = Dl_info()
            guard dladdr(ptr, &info) != 0,
                  let uuid = binaryUUID(base: info.dli_fbase) else { return }

            let offset = UInt(bitPattern: ptr) - UInt(bitPattern: info.dli_fbase)
            let defaults = UserDefaults(suiteName: Constants.appGroupID)!
            defaults.set(String(offset), forKey: Constants.ctxOffsetKey)
            defaults.set(uuid.uuidString, forKey: Constants.ctxUUIDKey)
            defaults.synchronize()
        }
    }

    static func update(sessionId: UUID, userId: String? = nil) {
        storage.set(sessionId: sessionId)
        storage.set(userId: userId)
    }

    static func setMetadata(_ key: String, value: String) {
        storage.set(string: value, forKey: key)
    }

    static func setMetadata(_ key: String, value: Int) {
        storage.set(int: value, forKey: key)
    }

    static func clearMetadata(_ key: String) {
        storage.clear(key: key)
    }
}

// MARK: - Mach-O UUID

private let kMH_MAGIC_64: UInt32 = 0xfeedfacf
private let kLC_UUID: UInt32 = 0x1b

private func binaryUUID(base: UnsafeRawPointer) -> UUID? {
    let header = base.assumingMemoryBound(to: mach_header_64.self)
    guard header.pointee.magic == kMH_MAGIC_64 else { return nil }
    var ptr = base.advanced(by: MemoryLayout<mach_header_64>.size)
    for _ in 0..<Int(header.pointee.ncmds) {
        let cmd = ptr.assumingMemoryBound(to: load_command.self)
        if cmd.pointee.cmd == kLC_UUID {
            return UUID(uuid: ptr.assumingMemoryBound(to: uuid_command.self).pointee.uuid)
        }
        ptr = ptr.advanced(by: Int(cmd.pointee.cmdsize))
    }
    return nil
}
