//
//  Answer.swift
//  Wordler
//
//  Created by Aaron Nance on 5/15/24.
//

import Foundation
import APNUtil

/// Data structure for describing the answer to a specific Wordle puzzle on a specific date.
/// - important: two `Answer`s are considered equal if they have the same word value
struct Answer: Manageable {
    
    var managedID: ManagedID?
    var word: Word
    var answerNum: Int?
    var date: Date?
    
    var description: String {
        
        "#\(answerNumDescription) \(word.uppercased()) on \(date!.simple)"
        
        
    }
}

extension Answer: CustomStringConvertible {
    
    var answerNumDescription: String {
        
        let footnote = answerNum.isNil ? "*" : ""
        
        return "\(answerNum?.description ?? computedAnswerNum.description)\(footnote)"
        
    }
    
    var computedAnswerNum: Int {
        
        let date = date!.simple.simpleDate // Get around locale issues.
        
        return date.daysFrom(earlierDate: Configs.Settings.Puzzle.historicalFirstDate)
        
    }
    
}

extension Answer: Equatable {
    
    static func ==(lhs: Answer, rhs: Answer) -> Bool {
        
        lhs.word == rhs.word
        
    }
}
