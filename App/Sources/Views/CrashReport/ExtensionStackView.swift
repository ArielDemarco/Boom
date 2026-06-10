//
//  ExtensionStackView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ExtensionStackView: View {
    let threadIndex: Int
    var threadName: String? = nil
    let frames: [ExtensionFrame]

    var body: some View {
        List(frames) { frame in
            HStack(alignment: .top, spacing: 8) {
                Text("\(frame.id)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 28, alignment: .trailing)
                VStack(alignment: .leading, spacing: 2) {
                    if let binary = frame.binaryName {
                        Text(binary)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if frame.symbol.isEmpty {
                        Text("0x\(String(format: "%016x", frame.rawAddress ?? 0))")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(frame.symbol)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(2)
                    }
                    HStack(spacing: 6) {
                        Text("+\(frame.offset)")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.tertiary)
                        if frame.isInline {
                            Text("inline")
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(.gray, in: Capsule())
                        }
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        }
        .navigationTitle(threadName ?? "Thread \(threadIndex)")
    }
}
