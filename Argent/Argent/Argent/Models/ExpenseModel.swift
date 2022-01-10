//
//  ExpenseModel.swift
//  Argent
//
//  Created by Christine Ong on 1/1/22.
//

import Foundation
import Firebase

struct Expense{
    let amount: Double
    let category: String
    let date: TimeInterval
    let iden: String
    let user: String
    let currDate: String
}
