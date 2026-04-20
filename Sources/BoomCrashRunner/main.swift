//
//  main.swift
//  BoomCrashRunner
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
//  CLI tool used by TriggerTests to run a crash in an isolated subprocess.
//  Usage: BoomCrashRunner <CrashClassName>
//
import Foundation
import Boom

private let crashes: [String: any Crash] = [
    "ForceUnwrapCrash": ForceUnwrapCrash(),
    "ArrayOutOfBoundsCrash": ArrayOutOfBoundsCrash(),
    "StackOverflowCrash": StackOverflowCrash(),
    "FatalErrorCrash": FatalErrorCrash(),
    "AssertionCrash": AssertionCrash(),
    "PreconditionCrash": PreconditionCrash(),
    "IntegerOverflowCrash": IntegerOverflowCrash(),
    "DivisionByZeroCrash": DivisionByZeroCrash(),
    "AbortCrash": AbortCrash(),
    "NullPointerCrash": NullPointerCrash(),
    "SIGSEGVCrash": SIGSEGVCrash(),
    "SIGBUSCrash": SIGBUSCrash(),
    "SIGILLCrash": SIGILLCrash(),
    "SIGFPECrash": SIGFPECrash(),
    "DeadlockCrash": DeadlockCrash(),
    "AsyncSafeThreadCrash": AsyncSafeThreadCrash(),
    "ObjCExceptionCrash": ObjCExceptionCrash(),
    "CXXExceptionCrash": CXXExceptionCrash(),
    "ObjCMsgSendCrash": ObjCMsgSendCrash(),
    "UnrecognizedSelectorCrash": UnrecognizedSelectorCrash(),
    "KVOCrash": KVOCrash(),
    "ReleasedObjectCrash": ReleasedObjectCrash(),
    "CorruptMallocCrash": CorruptMallocCrash(),
    "OOMKillCrash": OOMKillCrash(),
    "StackSmashCrash": StackSmashCrash(),
]

let name = CommandLine.arguments.dropFirst().first ?? ""

guard let crash = crashes[name] else {
    let available = crashes.keys.sorted().joined(separator: "\n  ")
    fputs("Unknown crash: \(name)\nAvailable:\n  \(available)\n", stderr)
    exit(1)
}

crash.trigger()
