//
//  WordlerRem.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import UIKit
import ConsoleView

/// Returns a list of all remembered answers.
@available(iOS 15, *)
struct WordlerRem: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    var commandToken    = Configs.Settings.Console.Commands.Tokens.rem
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.rem
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        let arg1 = args.elementNum(0).lowercased()
        
        if arg1 == "count" {
            
            return CommandOutput.output("\(solver.rememberedAnswers.count) answers remembered.") /*EXIT*/
            
        }
        
        var remembered = Array(solver.rememberedAnswers)
            .sorted{ $0.date! < $1.date! }
            .reduce(""){ "\($0)\n\($1.description)"}
        
        remembered = remembered.replacingOccurrences(of: "on ", with: " ")
        remembered = remembered.replacingOccurrences(of: " +", with: "  ", options: [.regularExpression])
        remembered = remembered.replacingOccurrences(of: "*  ", with: "* ")
        
        return CommandOutput.output(remembered,
                                    overrideFGColor: Configs.UI.Color.wordleGrayLight)
        
    }
}
