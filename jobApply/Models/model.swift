//
//  model.swift
//  jobApply
//
//  Created by 原里駆 on 2025/02/28.
//

import Foundation
import SwiftData

@Model
class CompanyModel {
    var level: Companylevel
    var companyName: String
    var currentState: ApplicationStatus
    var memo: String?
    var nextDate: Date?
    
    init(Level: Companylevel, companyName: String, currentState: ApplicationStatus, memo: String? = nil, nextDate: Date? = nil) {
        self.level = Level
        self.companyName = companyName
        self.currentState = currentState
        self.memo = memo
        self.nextDate = nextDate
    }
}

enum Companylevel: String, Codable, CaseIterable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
}

enum ApplicationStatus: String, Codable, CaseIterable {
    case pass = "内定"
    case final = "最終"
    case third = "3次"
    case second = "2次"
    case first = "1次"
    case ES = "ES提出"
    case finish = "終了"
}
