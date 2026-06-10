//
//  CrashReportLoadState.swift
//  BoomApp
//
//  Created by Ariel Demarco on 18/04/2026.
//

enum CrashPayload {
    case structured(CrashReportPayload)
    case dump(String)
}

enum CrashReportLoadState {
    case loading
    case loaded(CrashPayload)
    case failed
}
