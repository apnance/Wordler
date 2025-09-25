//
//  WordlerAdd.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import Foundation
import ConsoleView

/// Adds a word to Wordler's remembered word list.
@available(iOS 15, *)
struct WordlerAdd: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    static var flags: [Token] = []
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.add
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.add
    
    let validationPattern: CommandArgPattern? = Configs.Settings.Console.Commands.Validation.add
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        var i = 0
        var output = CommandOutput.empty
        
        repeat {
            
            let word = args.elementNum(i).uppercased()
            let date = args.elementNum(i + 1).simpleDateMaybe
            
            i += date.isNotNil ? 2 : 1
            
            if Solver.validate(word) {
                
                solver.archive(word, date: date, confirmAdd: false)
                output += CommandOutput.note("Wordler remembered -> '\(word)' \(date?.simple ?? "")\n")
                
            } else {
                
                output += CommandOutput.error(msg: "'\(word)' is not a valid 5 letter word.")
                
            }
            
        } while args.elementNum(i).isNotEmpty
        
        return output
        
    }
    
}

