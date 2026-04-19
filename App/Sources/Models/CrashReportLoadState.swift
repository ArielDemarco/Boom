//
//  CrashReportLoadState.swift
//  BoomApp
//
//  Created by Ariel Demarco on 18/04/2026.
//

enum CrashReportLoadState {
    case loading
    case loaded(CrashReportPayload)
    case failed
}
