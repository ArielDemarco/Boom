//
//  CrashRegistry.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

@MainActor
public final class CrashRegistry {
    public static let shared = CrashRegistry()

    private(set) var crashes: [any Crash] = []

    private init() {
        registerDefaults()
    }

    public func register(_ crash: any Crash) {
        crashes.append(crash)
    }

    public func crashes(in category: CrashCategory) -> [any Crash] {
        crashes.filter { $0.category == category }
    }

    private func registerDefaults() {
        // Swift Runtime
        register(ForceUnwrapCrash())
        register(ArrayOutOfBoundsCrash())
        register(StackOverflowCrash())
        register(FatalErrorCrash())
        register(AssertionCrash())
        register(PreconditionCrash())
        register(IntegerOverflowCrash())
        register(DivisionByZeroCrash())
        // Signal
        register(AbortCrash())
        register(NullPointerCrash())
        register(SIGSEGVCrash())
        register(SIGBUSCrash())
        register(SIGILLCrash())
        register(SIGFPECrash())
        register(StackSmashCrash())
        // Thread
        register(DeadlockCrash())
        register(AsyncSafeThreadCrash())
        // ObjC / Exception
        register(ObjCExceptionCrash())
        register(CXXExceptionCrash())
        register(ObjCMsgSendCrash())
        register(UnrecognizedSelectorCrash())
        register(KVOCrash())
        register(ReleasedObjectCrash())
        register(CorruptMallocCrash())
        // Memory
        register(OOMKillCrash())
    }
}
