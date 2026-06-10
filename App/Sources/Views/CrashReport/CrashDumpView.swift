//
//  CrashDumpView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ExtensionFrame: Identifiable {
    let id: Int
    let symbol: String
    let offset: Int
    let isInline: Bool
    let binaryName: String?
    let rawAddress: UInt64?
}

struct ExtensionThread: Identifiable {
    let id: Int
    let name: String?
    let frames: [ExtensionFrame]
}

struct CrashDumpView: View {
    let json: String
    @State private var copied = false

    private var parsed: [String: Any]? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    private var extThreads: [ExtensionThread] {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rawThreads = obj["threads"] as? [[String: Any]] else { return [] }

        let images = binaryImageLookups(from: obj)

        return rawThreads.enumerated().compactMap { idx, threadDict in
            guard let groups = threadDict["frameGroups"] as? [[[String: Any]]] else { return nil }
            let addresses = threadDict["frameAddresses"] as? [Int] ?? []

            var frames = [ExtensionFrame]()
            for (i, group) in groups.enumerated() {
                let addr = i < addresses.count ? UInt64(bitPattern: Int64(addresses[i])) : 0
                let binary = addr > 0 ? binaryName(for: addr, in: images) : nil
                for frame in group {
                    frames.append(ExtensionFrame(
                        id: frames.count,
                        symbol: frame["symbol"] as? String ?? "",
                        offset: frame["symbolOffset"] as? Int ?? 0,
                        isInline: frame["isInline"] as? Bool ?? false,
                        binaryName: binary,
                        rawAddress: addr > 0 ? addr : nil
                    ))
                }
            }
            guard !frames.isEmpty else { return nil }
            let name = threadDict["name"] as? String
            return ExtensionThread(id: idx, name: name, frames: frames)
        }
    }

    var body: some View {
        List {
            if let p = parsed {
                Section("Crash") {
                    if let reason = p["reason"] as? [String: Any] {
                        if let exc = reason["exception"] as? Int {
                            LabeledContent("Exception", value: "\(exc)")
                        }
                        if let codes = reason["codes"] as? [Int], !codes.isEmpty {
                            LabeledContent("Codes", value: codes.map {
                                "0x\(String(UInt(bitPattern: $0), radix: 16, uppercase: true))"
                            }.joined(separator: ", "))
                        }
                    }
                    if let os = p["osVersion"] as? String { LabeledContent("OS", value: os) }
                    if let device = p["deviceType"] as? String { LabeledContent("Device", value: device) }
                    if let arch = p["architecture"] as? String { LabeledContent("Architecture", value: arch) }
                    if let version = p["appVersion"] as? String { LabeledContent("App version", value: version) }
                }

                let threads = extThreads
                if !threads.isEmpty {
                    Section("Threads (\(threads.count))") {
                        ForEach(threads) { thread in
                            NavigationLink {
                                ExtensionStackView(threadIndex: thread.id, threadName: thread.name, frames: thread.frames)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(thread.name ?? "Thread \(thread.id)")
                                        .font(.body)
                                    Text("\(thread.frames.count) frames")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                let binaries = BinaryImageEntry.fromExtensionDumpJSON(json)
                if !binaries.isEmpty {
                    Section("Binary Images") {
                        NavigationLink("View \(binaries.count) images") {
                            BinaryImagesView(images: binaries)
                        }
                    }
                }
            }

            Section("Raw JSON") {
                Button {
                    copyToClipboard(json)
                    copied = true
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        copied = false
                    }
                } label: {
                    Label(
                        copied ? "Copied!" : "Copy to clipboard",
                        systemImage: copied ? "checkmark" : "doc.on.doc"
                    )
                }
            }
        }
        .navigationTitle("Crash Dump")
    }

    private func copyToClipboard(_ string: String) {
        #if os(iOS)
        UIPasteboard.general.string = string
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #endif
    }
}

// MARK: - Binary lookup
//
// The `size` field from BinaryImageInfo covers the full shared cache VM region,
// not the actual binary size — so range checks using base+size produce false matches.
// Instead, sort by base address and pick the largest base ≤ address (like atos/lldb do).

private struct BinaryImageLookup {
    let name: String
    let base: UInt64
}

private func binaryImageLookups(from obj: [String: Any]) -> [BinaryImageLookup] {
    guard let images = obj["binaryImages"] as? [[String: Any]] else { return [] }
    return images.compactMap { img -> BinaryImageLookup? in
        guard let baseStr = img["baseAddress"] as? String,
              let base = UInt64(baseStr.dropFirst(2), radix: 16),
              let path = img["path"] as? String else { return nil }
        return BinaryImageLookup(name: URL(fileURLWithPath: path).lastPathComponent, base: base)
    }.sorted { $0.base < $1.base }
}

private func binaryName(for address: UInt64, in images: [BinaryImageLookup]) -> String? {
    guard !images.isEmpty else { return nil }
    var lo = 0, hi = images.count - 1
    while lo < hi {
        let mid = (lo + hi + 1) / 2
        if images[mid].base <= address { lo = mid } else { hi = mid - 1 }
    }
    return images[lo].base <= address ? images[lo].name : nil
}
