//
//  CallStackThreadView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CallStackThreadView: View {
    let thread: CallStackThread

    var body: some View {
        Group {
            if thread.frames.isEmpty {
                ContentUnavailableView("No frames", systemImage: "waveform.path.ecg")
            } else {
                List(thread.frames) { frame in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(frame.id)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .trailing)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(frame.binaryName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text("\(frame.addressString)  +\(frame.offset)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
            }
        }
        .navigationTitle(thread.title)
    }
}
