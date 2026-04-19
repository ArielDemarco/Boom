//
//  CrashReportsView.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#if os(iOS)
import SwiftUI

struct CallStackView: View {
    let json: String
    @State private var copied = false

    var body: some View {
        ScrollView {
            Text(prettyJSON ?? json)
                .font(.system(.caption2, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle("Call Stack")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIPasteboard.general.string = json
                    copied = true
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        copied = false
                    }
                } label: {
                    Label(
                        copied ? "Copied!" : "Copy",
                        systemImage: copied ? "checkmark" : "doc.on.doc"
                    )
                }
            }
        }
    }

    private var prettyJSON: String? {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        else { return nil }
        return String(data: pretty, encoding: .utf8)
    }
}

#Preview {
    CallStackView(json: Thread.callStackSymbols.joined(separator: "\n"))
}
#endif


