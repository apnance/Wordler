//
//  Answer.swift
//  Wordler
//
//  Created by Aaron Nance on 5/15/24.
//

import Foundation
import APNUtil

struct Answer: Managable, CustomStringConvertible {
    
    var managedID: ManagedID?
    var word: Word
    var answerNum: Int?
    var date: Date?
    
    var description: String {
        
        "\(answerNum?.description ?? "nil") \(word.uppercased()) on \(date!.simple)"
        
    }
    
}
