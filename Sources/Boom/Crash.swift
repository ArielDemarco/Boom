//
//  Crash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

public enum CrashCategory: String, CaseIterable, Sendable {
    case signal = "Signal"
    case swiftRuntime = "Swift Runtime"
    case exception = "Exception"
    case memory = "Memory"
    case thread = "Thread"
}

public protocol Crash: AnyObject, Sendable {
    var category: CrashCategory { get }
    var title: String { get }
    var crashDescription: String { get }
    func trigger() -> Never
}
