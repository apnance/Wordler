//
//  WordlerRecap.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import ConsoleView

/// Outputs a running recap of the current solve session.
@available(iOS 15, *)
struct WordlerRecap: Command {
    
    // - MARK: Command Requirements
    var commandToken    = Configs.Settings.Console.Commands.Tokens.recap
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.recap
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        let vc          = Console.screen.viewController as? ViewController
        
        if let recapText = vc?.gameSummaryText {
            
            if recapText.isEmpty {
                
                return CommandOutput.warning("nothing to recap yet.")
                
            } else {
                
                return CommandOutput.output(recapText, overrideFGColor: Configs.UI.Color.wordleYellow)
                
            }
            
        } else {
            
            return CommandOutput.error(msg: "unable to access recap summary.")
            
        }
        
    }
}

