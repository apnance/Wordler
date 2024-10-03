//
//  WordlerPuzzleDate.swift
//  Wordler
//
//  Created by Aaron Nance on 10/2/24.
//

import Foundation
import ConsoleView

/// Outputs the date for a given puzzle number.  Output can be redirected to another command.
@available(iOS 15, *)
struct WordlerPuzzleDate: Command {
    
    // - MARK: Command Requirements
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.pdate
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.pdate
    
    func process(_ args: [String]?) -> CommandOutput {
        
        var arg1 = args.elementNum(0)
        
        guard let puzzleNum = Int(arg1)
        else {
            
            return console.screen!.format("'\(arg1)' is not a valid puzzle number.",
                                          target: .outputWarning)
            
        }
        
        let pdate   = Date.fromPuzzleNum(puzzleNum)!.simple
        var output  = console.screen!.format("Puzzle #\(puzzleNum) ran on \(pdate)",
                                             target: .output)
        output.raw  = pdate
        
        return output
        
    }
    
}

