//
//  WordlerAdd.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import ConsoleView

/// Adds a word to Wordler's remembered word list.
@available(iOS 15, *)
struct WordlerAdd: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.add
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.add
    
    func process(_ args: [String]?) -> CommandOutput {
        
        let consoleView = console.screen!
        
        guard let args = args,
              args.count > 0
        else {
            
            return consoleView.formatCommandOutput("\n[ERROR] Please specify valid 5 letter word(s) to add.") /*EXIT*/
            
        }
        
        var output  = ""
        var words = [Word]()
        
        for arg in args {
            
            if arg.count == 5 {
                
                words.append(arg)
                
            } else {
                
                output += "\n[ERROR] \(arg) is not a valid 5 letter word."
                
            }
            
        }
        
        for word in words {
            
            let word = word.uppercased()
            solver.archive(word, confirmAdd: false)
            output += "\nAdded Word: \(word)"
            
        }
        
        return consoleView.formatCommandOutput(output)
        
    }
}

