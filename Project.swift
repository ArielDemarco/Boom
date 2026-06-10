import ProjectDescription

let appGroupID = "group.com.ademarco.boomapp"

let project = Project(
    name: "BoomApp",
    packages: [
        .local(path: ".")
    ],
    settings: .settings(
        base: ["SWIFT_VERSION": "6.0"]
    ),
    targets: [
        .target(
            name: "BoomApp",
            destinations: [.iPhone, .iPad, .mac],
            product: .app,
            bundleId: "com.ademarco.boomapp",
            deploymentTargets: .multiplatform(iOS: "18.0", macOS: "15.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary(["UIImageName": .string("")])
            ]),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            entitlements: .dictionary([
                "com.apple.security.application-groups": .array([.string(appGroupID)])
            ]),
            dependencies: [
                .package(product: "Boom"),
                .target(name: "BoomCrashExtension"),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Automatic",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configs/Local.xcconfig"),
                    .release(name: "Release", xcconfig: "Configs/Local.xcconfig"),
                ]
            )
        ),
        .target(
            name: "BoomCrashExtension",
            destinations: [.mac, .iPhone, .iPad],
            product: .extensionKitExtension,
            bundleId: "com.ademarco.boomapp.crash-extension",
            deploymentTargets: .multiplatform(iOS: "27.0", macOS: "27.0"),
            infoPlist: .extendingDefault(with: [
                "EXAppExtensionAttributes": .dictionary([
                    "EXExtensionPointIdentifier": .string("com.apple.crash-reporter.extension")
                ])
            ]),
            sources: ["CrashExtension/Sources/**"],
            entitlements: .dictionary([
                "com.apple.security.application-groups": .array([.string(appGroupID)])
            ]),
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Automatic"
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configs/Local.xcconfig"),
                    .release(name: "Release", xcconfig: "Configs/Local.xcconfig"),
                ]
            )
        ),
    ]
)
