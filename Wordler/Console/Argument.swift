//
//  Argument.swift
//  Wordler
//
//  Created by Aaron Nance on 10/4/24.
//

import Foundation

enum ArgType { case date, puzzlenum, word, option, unknown }

/// Custom treatment of String for when they are used as arguments to `Command`s
typealias Argument  = String
extension Argument {
    
    var type: ArgType {
        
        if Int(self).isNotNil { return .puzzlenum                   /*EXIT*/ }
        else if Argument.isWord(self, ofLen: 1) { return .option    /*EXIT*/ }
        else if Argument.isWord(self, ofLen: 5) { return .word      /*EXIT*/ }
        else if self.simpleDateMaybe.isNotNil { return .date        /*EXIT*/ }
        else { return .unknown                                      /*EXIT*/ }
        
    }
    
    static func isWord(_ word: String,
                       ofLen chars: Int) -> Bool {
        
        let pattern = "^[a-zA-Z]{\(chars)}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        let range = NSRange(location: 0, length: word.utf16.count)
        if regex.firstMatch(in: word, options: [], range: range).isNotNil {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}
