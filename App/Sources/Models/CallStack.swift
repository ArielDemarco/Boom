//
//  CallStack.swift
//  BoomApp
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct CallStackFrame: Identifiable {
    let id: Int
    let binaryName: String
    let address: UInt64
    let offset: Int

    var addressString: String { "0x\(String(format: "%011x", address))" }
}

struct CallStackThread: Identifiable {
    let id: Int
    let isAttributed: Bool
    let frames: [CallStackFrame]

    var title: String { "Thread \(id)\(isAttributed ? " (Crashed)" : "")" }
}

extension CallStackThread {
    static func parse(from json: String) -> [CallStackThread] {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let callStacks = obj["callStacks"] as? [[String: Any]] else { return [] }

        return callStacks.enumerated().map { i, threadDict in
            let attributed = threadDict["threadAttributed"] as? Bool ?? false
            let roots = threadDict["callStackRootFrames"] as? [[String: Any]] ?? []

            var rawFrames = [[String: Any]]()
            collectDFS(roots, into: &rawFrames)
            rawFrames.reverse()

            let frames = rawFrames.enumerated().map { j, frameDict in
                CallStackFrame(
                    id: j,
                    binaryName: frameDict["binaryName"] as? String ?? "???",
                    address: (frameDict["address"] as? Int).map { UInt64(bitPattern: Int64($0)) } ?? 0,
                    offset: frameDict["offsetIntoBinaryTextSegment"] as? Int ?? 0
                )
            }
            return CallStackThread(id: i, isAttributed: attributed, frames: frames)
        }
    }

    private static func collectDFS(_ frames: [[String: Any]], into result: inout [[String: Any]]) {
        for frame in frames {
            result.append(frame)
            if let sub = frame["subFrames"] as? [[String: Any]] {
                collectDFS(sub, into: &result)
            }
        }
    }
}
