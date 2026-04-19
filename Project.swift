import ProjectDescription

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
            dependencies: [
                .package(product: "Boom")
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
        )
    ]
)
