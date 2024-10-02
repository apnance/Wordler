//
//  WordlerOutputCSV.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import UIKit
import APNUtil
import ConsoleView

/// Outputs a comma separated file of all remembered data to console and pasteboard.
@available(iOS 15, *)
struct WordlerOutputCSV: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.csv
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.csv
    
    func process(_ args: [String]?) -> CommandOutput {
        
        let csv = Array(solver.rememberedAnswers)
            .sorted{ $0.date! < $1.date! }
            .reduce(""){ "\($0)\n\($1.descriptionCSV)"}
        
        printToClipboard(csv)
        
        var atts = console.screen.formatCommandOutput("""
            \(csv)
            
            [Note: above output copied to pasteboard]
            """)
        
        atts.formatted.foregroundColor    = UIColor.lightGray
        
        return atts
        
    }
}
