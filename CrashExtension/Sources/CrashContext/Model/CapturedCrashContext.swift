//
//  CapturedCrashContext.swift
//  BoomApp
//
//  Created by Ariel Demarco on 12/06/2026.
//

import Foundation

struct CapturedCrashContext: Codable {
    let sessionId: String
    let userId: String?
    let metadata: [CapturedMetadataEntry]
}

struct CapturedMetadataEntry: Codable {
    let key: String
    let stringValue: String?
    let intValue: Int64?
}
