//
//  WordlerDict.swift
//  Wordler
//
//  Created by Aaron Nance on 10/9/24.
//

import ConsoleView

/// A command that indicates if a specified word is possible answer candidate.
@available(iOS 15, *)
struct WordlerDict: Command {
    
    var solver: Solver!
    
    // - MARK: Command Requirements
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.dict
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.dict
    
    func process(_ args: [String]?) -> CommandOutput {
        
        let word   = args.elementNum(0).uppercased()
        
        var output = "'\(word)' is not a valid 5-letter answer candidate."
        var target = FormatTarget.outputWarning
        
        if word.type == .word {
            
            if solver.hasWord(word) {
                
                target  = .output
                output  = "'\(word)' is a possible answer."
                
                if let previousAnswer = solver.getFor(word).first,
                   let date = previousAnswer.date?.simple {
                    
                    output += "\nIt was used in Puzzle #\(previousAnswer.computedPuzzleNum) on \(date)."
                    
                }
                
            } else {
                
                target  = .outputWarning
                output  = "'\(word)' is not a possible answer."
                
            }
            
        }
        
        return console.screen.format(output,
                                     target: target)
        
    }
}

