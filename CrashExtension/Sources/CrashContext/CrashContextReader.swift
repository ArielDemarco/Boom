//
//  CrashContextReader.swift
//  BoomCrashExtension
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if !targetEnvironment(simulator)
import CrashReportExtension
import Darwin
import Foundation

class CrashContextReader {
    private enum Constants {
        static let appGroupID = "group.com.ademarco.boomapp"
        static let ctxOffsetKey = "sdk.ctx_offset"
        static let ctxUUIDKey = "sdk.ctx_uuid"
    }
    
    func readCrashContext(from process: CrashedProcess) -> CapturedCrashContext? {
        guard let address = resolveContextAddress(in: process) else { return nil }
        
        let size = CrashContextStorage.size
        let rawBuffer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: CrashContextStorage.alignment)
        defer { rawBuffer.deallocate() }
        
        var bytesRead = vm_size_t(0)
        let kr = vm_read_overwrite(
            process.corpsePort,
            vm_address_t(address),
            vm_size_t(size),
            vm_address_t(bitPattern: rawBuffer),
            &bytesRead
        )
        
        guard kr == KERN_SUCCESS, Int(bytesRead) == size else { return nil }
        
        let storage = rawBuffer.load(as: CrashContextStorage.self)
        guard storage.magic == CrashContextStorage.expectedMagic else { return nil }
        
        let amountOfMetadata = min(Int(storage.metadataCount), CrashContextStorage.maxMetadataCount)
        let entries: [CapturedMetadataEntry] = (0..<amountOfMetadata).compactMap { i in
            let entry = storage.entry(at: i)
            guard entry.valueType != 0, !entry.key.isEmpty else { return nil }
            return CapturedMetadataEntry(
                key: entry.key,
                stringValue: entry.stringValue,
                intValue: entry.intValue
            )
        }
        
        return CapturedCrashContext(
            sessionId: storage.sessionUUID.uuidString,
            userId: storage.userId,
            metadata: entries
        )
    }

    private func resolveContextAddress(in process: CrashedProcess) -> UInt64? {
        let defaults = UserDefaults(suiteName: Constants.appGroupID)
        guard let offsetStr = defaults?.string(forKey: Constants.ctxOffsetKey),
              let offset = UInt64(offsetStr),
              let uuidStr = defaults?.string(forKey: Constatns.ctxUUIDKey),
              let targetUUID = UUID(uuidString: uuidStr) else { return nil }
        guard let image = process.binaryImages.first(where: { $0.uuid == targetUUID }) else { return nil }
        return image.baseAddress + offset
    }
}

#endif
