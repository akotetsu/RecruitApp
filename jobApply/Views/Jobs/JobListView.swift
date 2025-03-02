//
//  JobListView.swift
//  jobApply
//
//  Created by 原里駆 on 2025/02/28.
//

import SwiftUI
import SwiftData

struct JobListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var companies: [CompanyModel]
    @State private var showingAddCompanySheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(companies) { company in
                    NavigationLink(destination: JobDetailView(company: .constant(company))) {
                        CompanyRowView(company: company)
                    }
                }
            }
            .listStyle(PlainListStyle()) // より現代的なリストスタイル
            .navigationTitle("選考企業一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCompanySheet = true}) {
                        Label("追加", systemImage: "plus")
                    }
                }
                if companies.isEmpty != true {
                    ToolbarItem(placement: .bottomBar) {
                        Text("\(companies.count) 社")
                    }
                }

            }
            .overlay {
                if companies.isEmpty {
                    ContentUnavailableView("0社", systemImage: "building", description: Text("現在選考中の企業はありません"))
                }
            }
            .sheet(isPresented: $showingAddCompanySheet) {
                AddCompanyView()
            }
        }
    }
}

struct CompanyRowView: View {
    let company: CompanyModel
    var body: some View {
        HStack {
            // ステータスインジケーター
            Text(company.level.rawValue)
                .font(.headline)
                .frame(width: 20, height: 20)
                .background(statusColor(for: company.level))
                .cornerRadius(4)
            
            // 企業名
            Text(company.companyName)
                .font(.title3)
                .lineLimit(1)
                .padding(.leading, 4)
            
            Spacer()
            
            // 右側の情報エリア - グリッドレイアウトで整列
            Grid(alignment: .trailing, horizontalSpacing: 4) {
                GridRow {
                    Text("現在")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .gridColumnAlignment(.trailing)
                    
                    Text(company.currentState.rawValue)
                        .font(.subheadline)
                        .gridColumnAlignment(.leading)
                }
                
                GridRow {
                    Text("次回")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .gridColumnAlignment(.trailing)
                    
                    if let nextDate = company.nextDate {
                        Text(FormatterUtils.formatDate(nextDate))
                            .font(.caption)
                            .gridColumnAlignment(.leading)
                    } else {
                        Text("未定")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .gridColumnAlignment(.leading)
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 8)
    }
    
    private func statusColor(for level: Companylevel) -> Color {
        switch level {
        case .s:
            return .yellow
        case .a:
            return .green
        case .b:
            return .pink
        case .c:
            return .blue
        case .d:
            return .red
        }
    }
}
#Preview("Emrty") {
    JobListView()
        .modelContainer(for: CompanyModel.self, inMemory: true)
}

