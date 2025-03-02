//
//  ScheduleView.swift
//  jobApply
//
//  Created by 原里駆 on 2025/02/28.
//

import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Query private var companies: [CompanyModel]
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                calendarHeader
                weekdayHeader
                calendarGrid
                scheduleList
            }
            .navigationTitle("スケジュール")
        }
    }
    
    // カレンダーヘッダー（月切り替え）
    private var calendarHeader: some View {
        HStack {
            Button(action: { moveMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            Text(monthYearString(from: currentMonth))
                .font(.title2)
            
            Spacer()
            
            Button(action: { moveMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }
    
    // 曜日ヘッダー
    private var weekdayHeader: some View {
        HStack {
            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(day == "日" ? .red : .primary)
            }
        }
    }
    
    // カレンダーグリッド（日付）
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(daysInMonth(for: currentMonth), id: \.self) { date in
                if let date = date {
                    let hasEvent = hasEvent(on: date)
                    
                    Button(action: {
                        selectedDate = date
                    }) {
                        Text(String(Calendar.current.component(.day, from: date)))
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(isSelected(date: date) ? Color.blue.opacity(0.3) : nil)
                            .foregroundColor(isToday(date: date) ? .blue : .primary)
                            .cornerRadius(8)
                            .overlay(
                                Circle()
                                    .fill(hasEvent ? Color.blue : Color.clear)
                                    .frame(width: 6, height: 6)
                                    .offset(y: 10),
                                alignment: .bottom
                            )
                    }
                } else {
                    Text("")
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // 予定リスト（選択日または近日の予定）
    private var scheduleList: some View {
        List {
            Section(header: Text("選択日の予定")) {
                ForEach(eventsForSelectedDate(), id: \.id) { company in
                    CompanyScheduleRow(company: company)
                }
                
                if eventsForSelectedDate().isEmpty {
                    Text("予定なし")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("今後の予定")) {
                ForEach(upcomingEvents(), id: \.id) { company in
                    CompanyScheduleRow(company: company)
                }
                
                if upcomingEvents().isEmpty {
                    Text("予定なし")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // 月を前後に移動するメソッド
    private func moveMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    // 月と年を表示するためのフォーマット文字列を生成
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
    
    // 指定した月の日付配列を取得（カレンダーグリッド用）
    private func daysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        
        // 月の初日を取得
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        // 月の初日の曜日を取得（0が日曜、1が月曜...）
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        
        // 月の日数を取得
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
        
        var days = [Date?](repeating: nil, count: firstWeekday)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        // 最終週を7日分埋める
        let remainingDays = 42 - days.count // 6週間分（7日×6週=42）
        if remainingDays > 0 && remainingDays < 7 {
            days += [Date?](repeating: nil, count: remainingDays)
        }
        
        return days
    }
    
    // 日付が今日かどうかを判定
    private func isToday(date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    // 日付が選択されているかを判定
    private func isSelected(date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    // 特定の日に予定があるかどうかを判定
    private func hasEvent(on date: Date) -> Bool {
        return companies.contains { company in
            if let nextDate = company.nextDate {
                return Calendar.current.isDate(nextDate, inSameDayAs: date)
            }
            return false
        }
    }
    
    // 選択された日付の予定を取得
    private func eventsForSelectedDate() -> [CompanyModel] {
        return companies.filter { company in
            if let nextDate = company.nextDate {
                return Calendar.current.isDate(nextDate, inSameDayAs: selectedDate)
            }
            return false
        }
    }
    
    // 今後の予定を日付順に取得（選択日以降の予定）
    private func upcomingEvents() -> [CompanyModel] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let filteredCompanies = companies.filter { company in
            if let nextDate = company.nextDate {
                let companyDate = calendar.startOfDay(for: nextDate)
                return companyDate > startOfDay
            }
            return false
        }
        
        return filteredCompanies.sorted { companyA, companyB in
            if let dateA = companyA.nextDate, let dateB = companyB.nextDate {
                return dateA < dateB
            }
            return false
        }.prefix(5).map { $0 } // 今後5件まで表示
    }
}

// 企業予定表示の行コンポーネント
struct CompanyScheduleRow: View {
    let company: CompanyModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(company.companyName)
                    .font(.headline)
                
                if let nextDate = company.nextDate {
                    Text(FormatterUtils.formatDate(nextDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(company.currentState.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScheduleView()
        .modelContainer(for: CompanyModel.self, inMemory: true)
}
