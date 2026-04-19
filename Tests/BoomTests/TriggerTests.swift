//
//  TriggerTests.swift
//  BoomTests
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if os(macOS)
import Darwin
import XCTest

final class TriggerTests: XCTestCase {
    //  Each test spawns BoomCrashRunner in a subprocess and asserts the process
    //  exits abnormally (terminationReason == .uncaughtSignal).
    //  Build the runner first with `swift build` if tests are skipping.
    //
    //  Signal values are verified empirically on ARM64. On x86_64, Swift runtime
    //  traps emit SIGILL instead of SIGTRAP (EXC_BAD_INSTRUCTION vs EXC_BREAKPOINT).
    //  I left some notes on each test, as the signal could change in release vs debug mode.

    // MARK: - Swift Runtime

    // release: same signal; force-unwrap always traps regardless of optimization level
    func test_forceUnwrap_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("ForceUnwrapCrash", signal: SIGTRAP)
    }

    // release (-O): same signal; Swift keeps bounds checks; only -Ounchecked removes them (SIGSEGV)
    func test_arrayOutOfBounds_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("ArrayOutOfBoundsCrash", signal: SIGTRAP)
    }

    // release: same signal; guard page hit is architecture/OS behavior, unaffected by optimization
    func test_stackOverflow_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("StackOverflowCrash", signal: SIGSEGV)
    }

    // release: same signal
    func test_fatalError_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("FatalErrorCrash", signal: SIGTRAP)
    }

    // release: assertionFailure() is a no-op / falls through to fatalError("unreachable") same signal
    func test_assertionFailure_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("AssertionCrash", signal: SIGTRAP)
    }

    // release: same signal; preconditionFailure() traps in all optimization levels
    func test_preconditionFailure_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("PreconditionCrash", signal: SIGTRAP)
    }

    // release (-O): same signal; Swift keeps overflow traps; only -Ounchecked removes them (no crash)
    func test_integerOverflow_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("IntegerOverflowCrash", signal: SIGTRAP)
    }

    // release: same signal; Swift adds a division-by-zero check on ARM64 (no hardware exception for int div/0)
    func test_divisionByZero_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("DivisionByZeroCrash", signal: SIGTRAP)
    }

    // MARK: - Signal

    // release: same; abort() behavior is independent of optimization level
    func test_abort_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("AbortCrash", signal: SIGABRT)
    }

    // Note: UnsafeMutablePointer(bitPattern: 0) returns nil on Darwin; ptr! force-unwraps is SIGTRAP
    // (the actual write to 0x0 never executes). release: same
    func test_nullPointer_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("NullPointerCrash", signal: SIGTRAP)
    }

    func test_sigsegv_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("SIGSEGVCrash", signal: SIGSEGV)
    }

    func test_sigbus_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("SIGBUSCrash", signal: SIGBUS)
    }

    func test_sigill_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("SIGILLCrash", signal: SIGILL)
    }

    func test_sigfpe_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("SIGFPECrash", signal: SIGFPE)
    }

    // MARK: - Thread

    // libdispatch detects the main-thread deadlock and calls __builtin_trap() (SIGTRAP)
    // release: same; this is system library behavior, not compilation-level
    func test_deadlock_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("DeadlockCrash", signal: SIGTRAP)
    }

    // Same note as NullPointerCrash: ptr! on a nil optional (SIGTRAP before touching address 0)
    // release: same.
    func test_asyncSafeThread_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("AsyncSafeThreadCrash", signal: SIGTRAP)
    }

    // MARK: - ObjC / Exception

    // release: same ; NSException termination calls abort() regardless of optimization level
    func test_objcException_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("ObjCExceptionCrash", signal: SIGABRT)
    }

    // release: same ; std::terminate calls abort()
    func test_cxxException_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("CXXExceptionCrash", signal: SIGABRT)
    }

    // release: same ; EXC_BAD_ACCESS on a dangling isa pointer is a runtime/hardware event
    func test_objcMsgSend_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("ObjCMsgSendCrash", signal: SIGSEGV)
    }

    // release: same
    func test_releasedObject_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("ReleasedObjectCrash", signal: SIGSEGV)
    }

    // release: same; on modern macOS, malloc_zone_error uses __builtin_trap() (SIGTRAP)
    func test_corruptMalloc_terminatesWithSignal() throws {
        try assertTerminatesWithSignal("CorruptMallocCrash", signal: SIGTRAP)
    }
}

// MARK: - Helpers

private extension TriggerTests {

    private func assertTerminatesWithSignal(
        _ crashName: String,
        signal: Int32,
        timeout: TimeInterval = 10
    ) throws {
        let runner = try crashRunnerURL()
        let process = Process()
        process.executableURL = runner
        process.arguments = [crashName]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()

        let exited = process.poll(within: timeout)
        XCTAssertTrue(exited, "\(crashName) did not terminate within \(timeout)s")
        XCTAssertEqual(
            process.terminationReason, .uncaughtSignal,
            "\(crashName) exited cleanly and we expected a signal termination"
        )
        XCTAssertEqual(
            process.terminationStatus, signal,
            "\(crashName) terminated with unexpected signal \(process.terminationStatus), expected \(signal)"
        )
        print("DEBUG \(crashName): exited with signal \(process.terminationStatus)")
    }

    /// Resolves the path to BoomCrashRunner by searching .build/ from the package root.
    /// Uses #file (compile-time path) to locate the root reliably, regardless of test runner.
    private func crashRunnerURL() throws -> URL {
        // #file: .../Tests/BoomTests/TriggerTests.swift; we need to go up 3 levels to package root
        let packageRoot = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let buildDir = packageRoot.appendingPathComponent(".build")
        let fm = FileManager.default

        // Search under each architecture directory (arm64-apple-macosx, x86_64-apple-macosx, etc.)
        if let archs = try fm.contentsOfDirectory(atPath: buildDir.path) {
            for arch in archs {
                let candidate = buildDir
                    .appendingPathComponent(arch)
                    .appendingPathComponent("debug")
                    .appendingPathComponent("BoomCrashRunner")
                if fm.fileExists(atPath: candidate.path) {
                    return candidate
                }
            }
        }

        throw XCTSkip("BoomCrashRunner not found in \(buildDir.path)... run `swift build` first")
    }
}

#endif
