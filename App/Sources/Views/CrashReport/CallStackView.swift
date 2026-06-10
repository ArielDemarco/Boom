//
//  CallStackView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CallStackView: View {
    let json: String

    private var threads: [CallStackThread] {
        CallStackThread.parse(from: json).filter { !$0.frames.isEmpty }
    }

    var body: some View {
        Group {
            if threads.isEmpty {
                ContentUnavailableView("No stack trace", systemImage: "waveform.path.ecg")
            } else {
                List(threads) { thread in
                    NavigationLink {
                        CallStackThreadView(thread: thread)
                    } label: {
                        HStack {
                            Text(thread.title)
                            Spacer()
                            if thread.isAttributed {
                                Text("crashed")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.red, in: Capsule())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Call Stacks")
    }
}
