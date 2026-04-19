//
//  RaiseSignalCrash.swift
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//
import Darwin

public final class SIGSEGVCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .signal
    public let title = "Raise SIGSEGV"
    public let crashDescription = "Explicitly raise SIGSEGV (segmentation fault) via raise(3)."

    public init() {}

    public func trigger() -> Never {
        raise(SIGSEGV)
        fatalError("unreachable")
    }
}

public final class SIGBUSCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .signal
    public let title = "Raise SIGBUS"
    public let crashDescription = "Explicitly raise SIGBUS (bus error) via raise(3)."

    public init() {}

    public func trigger() -> Never {
        raise(SIGBUS)
        fatalError("unreachable")
    }
}

public final class SIGILLCrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .signal
    public let title = "Raise SIGILL"
    public let crashDescription = "Explicitly raise SIGILL (illegal instruction) via raise(3)."

    public init() {}

    public func trigger() -> Never {
        raise(SIGILL)
        fatalError("unreachable")
    }
}

public final class SIGFPECrash: Crash, @unchecked Sendable {
    public let category: CrashCategory = .signal
    public let title = "Raise SIGFPE"
    public let crashDescription = "Explicitly raise SIGFPE (floating-point exception) via raise(3)."

    public init() {}

    public func trigger() -> Never {
        raise(SIGFPE)
        fatalError("unreachable")
    }
}
