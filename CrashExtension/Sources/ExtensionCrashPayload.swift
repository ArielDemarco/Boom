//
//  ExtensionCrashPayload.swift
//  BoomCrashExtension
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ExtensionCrashPayload: Codable {
    struct Reason: Codable {
        let exception: Int32
        let codes: [UInt64]
    }

    struct BinaryImage: Codable {
        let path: String
        let uuid: String?
        let baseAddress: String
        let size: UInt64
    }

    let capturedAt: Double
    let reason: Reason
    let binaryImages: [BinaryImage]
    let corpsePort: UInt32
    let osVersion: String
    let deviceType: String
    let architecture: String
    let appVersion: String
}
