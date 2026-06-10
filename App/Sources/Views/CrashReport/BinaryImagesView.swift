//
//  BinaryImagesView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct BinaryImageEntry: Identifiable {
    let id = UUID()
    let name: String
    let uuid: String?
    let baseAddress: String?
    let path: String?

    var displayName: String { path.flatMap { URL(string: $0)?.lastPathComponent } ?? name }
}

struct BinaryImagesView: View {
    let images: [BinaryImageEntry]

    var body: some View {
        List(images) { image in
            VStack(alignment: .leading, spacing: 2) {
                Text(image.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                if let uuid = image.uuid {
                    Text(uuid)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                if let base = image.baseAddress {
                    Text(base)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }
            }
            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        }
        .navigationTitle("Binary Images (\(images.count))")
    }
}

extension BinaryImageEntry {
    static func fromCallStackJSON(_ json: String) -> [BinaryImageEntry] {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let callStacks = obj["callStacks"] as? [[String: Any]] else { return [] }

        var seen = Set<String>()
        var result = [BinaryImageEntry]()

        func collectBinaries(_ frames: [[String: Any]]) {
            for frame in frames {
                let name = frame["binaryName"] as? String ?? ""
                let uuid = frame["binaryUUID"] as? String
                let key = "\(name)_\(uuid ?? "")"
                if !name.isEmpty && seen.insert(key).inserted {
                    result.append(BinaryImageEntry(name: name, uuid: uuid, baseAddress: nil, path: nil))
                }
                if let sub = frame["subFrames"] as? [[String: Any]] {
                    collectBinaries(sub)
                }
            }
        }

        for thread in callStacks {
            if let roots = thread["callStackRootFrames"] as? [[String: Any]] {
                collectBinaries(roots)
            }
        }
        return result
    }

    static func fromExtensionDumpJSON(_ json: String) -> [BinaryImageEntry] {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let images = obj["binaryImages"] as? [[String: Any]] else { return [] }

        return images.map { img in
            BinaryImageEntry(
                name: (img["path"] as? String).flatMap { URL(string: $0)?.lastPathComponent } ?? "unknown",
                uuid: img["uuid"] as? String,
                baseAddress: img["baseAddress"] as? String,
                path: img["path"] as? String
            )
        }
    }
}
