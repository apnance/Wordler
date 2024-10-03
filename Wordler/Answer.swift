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
    
    
    /// `self`'s computed puzzle number.
    var computedPuzzleNum: Int {
        
        date!.computedPuzzleNum
        
    }
    
}

extension Answer: CustomStringConvertible {
    
    var description: String {
        
        "#\(answerNumDescription) \(word.uppercased()) on \(date!.simple)"
        
        
    }
    
    /// Colon delimmited string value  fit for use in a .csv file.
    var descriptionCSV: String {
        
        "\(word.uppercased());\(answerNumDescription);\(date!.simple)"
        
    }
    
    var answerNumDescription: String {
        
        let footnote = answerNum.isNil ? "*" : ""
        
        return "\(answerNum?.description ?? computedPuzzleNum.description)\(footnote)"
        
    }
    
}

extension Date {
    
    /// `self`'s computed puzzle number.
    var computedPuzzleNum: Int {
        
        let date = simple.simpleDate  // Get around locale issues.
        return date.daysFrom(earlierDate: Configs.Settings.Puzzle.historicalFirstDate)
        
    }
    
    /// The computed number for today's game's answer.
    static var todaysPuzzleNum: Int { Date().computedPuzzleNum }
    
    /// Converts a puzzle number into a `Date` formatted as a "MM/dd/yy".
    /// - Parameter puzzleNum: the number of a specified puzzle.  Can also be
    /// viewed as the number of days since the original game of Wordle was first played.
    /// - Returns: optional date specifying on what day the puzzle numbered
    /// `puzzleNum` ran on Wordle.
    static func fromPuzzleNum(_ num: Int) -> Date? {
        
        Configs.Settings.Puzzle.historicalFirstDate.shiftedBy(num)
        
    }
    
}

extension Answer: Equatable {
    
    static func ==(lhs: Answer, rhs: Answer) -> Bool {
        
        lhs.word == rhs.word
        
    }
}
