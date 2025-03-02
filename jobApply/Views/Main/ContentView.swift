//
//  ContentView.swift
//  jobApply
//
//  Created by 原里駆 on 2025/02/28.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            JobListView()
                .tabItem {
                    Label("企業一覧", systemImage: "building")
                }
                .tag(0)
            ScheduleView()
                .tabItem {
                    Label("予定", systemImage: "calendar")
                }
                .tag(1)
            StaticsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    ContentView()
}
