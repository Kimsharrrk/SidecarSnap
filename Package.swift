// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SidecarSnap",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "SidecarSnap",
            path: "Sources/SidecarSnap",
            linkerSettings: [
                // Info.plist를 바이너리에 직접 임베드
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Resources/Info.plist"
                ])
            ]
        )
    ]
)
