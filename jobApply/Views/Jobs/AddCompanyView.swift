//
//  AddCompanyView.swift
//  jobApply
//
//  Created by 原里駆 on 2025/02/28.
//

import SwiftUI
import SwiftData

struct AddCompanyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var Level = Companylevel.a
    @State private var companyName = ""
    @State private var currentState = ApplicationStatus.first
    @State private var nextDate = Date()
    @State private var hasnextDate = true //次回日程があるかどうかをチェック
    @State private var memo = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("企業名", text: $companyName)
                    Picker("志望度", selection: $Level) {
                        ForEach(Companylevel.allCases, id: \.self) { Level in
                            Text(Level.rawValue).tag(Level)
                        }
                    }
                    Picker("現在のフェーズ", selection: $currentState) {
                        ForEach(ApplicationStatus.allCases, id: \.self) { currentState in
                            Text(currentState.rawValue).tag(currentState)
                        }
                    }
                    Toggle("次回日程あり", isOn: $hasnextDate)
                    
                    if hasnextDate {
                        DatePicker("次回の日程", selection: $nextDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("メモ")) {
                    TextEditor(text: $memo)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("企業を追加")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        addCompany()
                        dismiss()
                    }
                    .disabled(companyName.isEmpty)
                }
            }
        }
    }
    
    private func addCompany() {
        let company = CompanyModel(
            Level: Level,
            companyName: companyName,
            currentState: currentState,
            memo: memo.isEmpty ? nil : memo,
            nextDate: hasnextDate ? nextDate : nil
        )
        
        modelContext.insert(company)
    }
}

#Preview {
    AddCompanyView()
        .modelContainer(for: CompanyModel.self, inMemory: true)
}
