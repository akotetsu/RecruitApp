//
//  JobDetailView.swift
//  jobApply
//
//  Created by 原里駆 on 2025/02/28.
//

import SwiftUI
import SwiftData

struct JobDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var company: CompanyModel
    @State private var isEditing = false
    @State private var hasNextDate: Bool = true
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("基本情報")) {
                    if isEditing {
                        TextField("企業名", text: $company.companyName)
                        Picker("志望度", selection: $company.level) {
                            ForEach(Companylevel.allCases, id: \.self) { Level in
                                Text(Level.rawValue).tag(Level)
                            }
                        }
                        Picker("現在のフェーズ", selection: $company.currentState) {
                            ForEach(ApplicationStatus.allCases, id: \.self) { currentState in
                                Text(currentState.rawValue).tag(currentState)
                            }
                        }
                        Toggle("次回日程あり", isOn: $hasNextDate)
                        
                        if hasNextDate {
                            DatePicker("次回の日程", selection: Binding(
                                get: { company.nextDate ?? Date() },
                                set: { company.nextDate = $0 }
                            ), displayedComponents: .date)
                        }
                    }
                    else {
                        LabeledContent("企業名", value: company.companyName)
                        LabeledContent("志望度", value: company.level.rawValue)
                        LabeledContent("現在のフェーズ", value: company.currentState.rawValue)
                        if let nextDate = company.nextDate {
                            LabeledContent("次回の日程", value: FormatterUtils.formatDateMedium(nextDate))
                        } else {
                            LabeledContent("次回の日程", value: "未設定")
                        }
                    }
                }
                Section(header: Text("メモ")) {
                    if isEditing {
                        TextEditor(text: Binding(
                            get: { company.memo ?? "" },
                            set: { company.memo = $0.isEmpty ? nil : $0 }
                        ))
                        .frame(minHeight: 100)
                    } else {
                        Text(company.memo ?? "メモなし")
                    }
                }
            }
            
            // 削除ボタン
            Button(action: {
                showingDeleteAlert = true
            }) {
                Text("削除")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "完了" : "編集") {
                    if isEditing {
                        if !hasNextDate {
                            company.nextDate = nil
                        }
                    } else {
                        hasNextDate = company.nextDate != nil
                    }
                    isEditing.toggle()
                }
            }
        }
        .onAppear {
            hasNextDate = company.nextDate != nil
        }
        .alert("削除の確認", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                deleteCompany()
            }
        } message: {
            Text("\(company.companyName)の情報を削除します。この操作は元に戻せません。")
        }
    }
    
    private func deleteCompany() {
        modelContext.delete(company)
        dismiss()
    }
}

#Preview {
    ContentView()
}
