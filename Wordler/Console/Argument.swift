//
//  Argument.swift
//  Wordler
//
//  Created by Aaron Nance on 10/4/24.
//

import Foundation

enum ArgType { case date, puzzleNum, puzzlenNumRange, word, option, unknown }

/// Custom treatment of String for when they are used as arguments to `Command`s
typealias Argument  = String
extension Argument {
    
    var type: ArgType {
        
        if isNumeric() { return .puzzleNum              /*EXIT*/ }
        else if isWord(ofLen: 1) { return .option       /*EXIT*/ }
        else if isWord(ofLen: 5) { return .word         /*EXIT*/ }
        else if isRange() { return .puzzlenNumRange     /*EXIT*/ }
        else if simpleDateMaybe.isNotNil { return .date /*EXIT*/ }
        else { return .unknown                          /*EXIT*/ }
        
    }
    
    private func isNumeric() -> Bool { matches("^[0-9]+$") }
    private func isRange() -> Bool { matches("^[0-9]+-[0-9]+$") }
    private func isWord(ofLen chars: Int) -> Bool { matches("^[a-zA-Z]{\(chars)}$") }
    
    private func matches(_ regExp:String) -> Bool {
  
        let rx = try! NSRegularExpression(pattern: regExp)
        let rg = NSRange(location: 0, length: utf16.count)
        
        return rx.firstMatch(in: self, range: rg).isNotNil /*EXIT*/
        
    }
    
}
