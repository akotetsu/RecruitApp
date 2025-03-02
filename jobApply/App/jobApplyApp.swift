//
//  jobApplyApp.swift
//  jobApply
//
//  Created by 原里駆 on 2025/02/28.
//

import SwiftUI
import SwiftData

@main
struct jobApplyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: CompanyModel.self)
        }
    }
}
