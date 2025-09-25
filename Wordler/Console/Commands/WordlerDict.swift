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
    static var flags: [Token] = []
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.dict
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.dict
    
    let validationPattern: CommandArgPattern? = Configs.Settings.Console.Commands.Validation.dict
    
    func process(_ args: [String]?) -> CommandOutput {
        
        let word   = args.elementNum(0).uppercased()
        
        var output = CommandOutput.warning("'\(word)' is not a valid 5-letter answer candidate.")
        
        if word.type == .word {
            
            if solver.hasWord(word) {
                
                output  = CommandOutput.note("'\(word)' is a possible answer.\n")
                
                if let previousAnswer = solver.getFor(word).first,
                   let date = previousAnswer.date?.simple {
                    
                    output += CommandOutput.warning("it was used in Puzzle #\(previousAnswer.computedPuzzleNum) on \(date).")
                    
                } else {
                    
                    output += CommandOutput.note("it has not yet been used in a Wordle puzzle.")
                    
                }
                
            } else {
                
                output = CommandOutput.warning("'\(word)' is not a possible answer.")
                
            }
            
        }
        
        return output
        
    }
    
}

