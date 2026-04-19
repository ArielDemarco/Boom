# Boom

A macOS/iOS app and Swift library for triggering on-demand crashes to test crash reporters, symbolication pipelines, and MetricKit integration.

## How to use Boom

Import `Boom` to access the crash registry and trigger crashes programmatically.

```swift
import Boom

// Use the shared registry
let crashes = CrashRegistry.shared.crashes
let signalCrashes = CrashRegistry.shared.crashes(in: .signal)

// Trigger a crash
CrashRegistry.shared.crashes.first?.trigger()
```

> [!WARNING]
> Crash behavior and signal numbers can differ between debug and release builds. See [Tests](#tests) for details.

### Crash categories

| Category      | Examples                                                            |
| ------------- | ------------------------------------------------------------------- |
| Swift Runtime | Force unwrap, array out of bounds, integer overflow, stack overflow |
| Signal        | `abort()`, `SIGSEGV`, `SIGBUS`, `SIGILL`, `SIGFPE`                  |
| Exception     | Uncaught ObjC exception, uncaught C++ exception                     |
| Memory        | ObjC zombie, corrupt malloc, released object                        |
| Thread        | Main thread deadlock, crash from background thread                  |

### Adding a custom crash

```swift
final class MyCustomCrash: Crash, @unchecked Sendable {
    let category: CrashCategory = .swiftRuntime
    let title = "My crash"
    let crashDescription = "What it does and what signal to expect."

    func trigger() -> Never {
        fatalError("boom")
    }
}

CrashRegistry.shared.register(MyCrash())
```

## App (BoomApp)

Requires [Tuist](https://tuist.io). Build and run with Xcode:

```bash
tuist generate
open BoomApp.xcworkspace
```

To run on a physical device (recommended, crash behavior differs between debug and release builds):

```bash
cp Configs/Local.xcconfig.template Configs/Local.xcconfig
# Set DEVELOPMENT_TEAM to your Apple Developer Team ID
tuist generate
open BoomApp.xcworkspace
```

## Tests

```bash
# Build the subprocess runner first, then run all tests
swift build
swift test
```

`trigger()` returns `Never` and kills the process, so it can't be tested in-process without taking down the test runner. `TriggerTests` works around this by spawning each crash in a separate executable (`BoomCrashRunner`), waiting for it to exit, and asserting that `terminationReason == .uncaughtSignal` with the expected signal number.

Signal values are verified empirically on ARM64. On x86_64, Swift runtime traps emit `SIGILL` instead of `SIGTRAP` (EXC_BAD_INSTRUCTION vs EXC_BREAKPOINT).

> [!WARNING]
> Signal values in these tests reflect **debug builds** (`-Onone`). In release (`-O`), most signals are identical, but there are exceptions: with `-Ounchecked`, integer overflow wraps silently (no crash) and bounds checks are removed (SIGSEGV instead of SIGTRAP). Each test has a comment noting the expected release behavior.

## Acknowledgements

Inspired by [CrashProbe](https://github.com/bitstadium/CrashProbe).

## License

This project is released under the MIT license.
