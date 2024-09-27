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
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.recap
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.recap
    
    func process(_ args: [String]?) -> CommandOutput {
        
        let vc          = (console.screen! as! ConsoleView)
        
        if let recapText = (vc.viewController as? ViewController)?.gameSummaryText {
            
            if recapText.isEmpty {
                
                return console.screen.format("[Warning] : Nothing to recap yet.",
                                             target: .outputWarning)
                
            } else {
                
                return console.screen.formatCommandOutput(recapText,
                                                          overrideColor: Configs.UI.Color.wordleYellow)
                
            }
            
        } else {
            
            return console.screen.format("[Error] : Unable to access recap summary.",
                                         target: .outputWarning)
            
        }
        
    }
}

