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
struct WordlerCSV: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    static var flags: [Token] = []
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.csv
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.csv
    
    let validationPattern: CommandArgPattern? = Configs.Settings.Console.Commands.Validation.csv
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        let csv = Array(solver.rememberedAnswers)
            .sorted{ $0.date! < $1.date! }
            .reduce(""){ "\($0)\n\($1.descriptionCSV)"}
        
        printToClipboard(csv)
        
        var output  = CommandOutput.output(csv, overrideFGColor: Configs.UI.Color.wordleGrayLight)
        
        output      += CommandOutput.note("copied to pasteboard.",
                                          newLines: 2)
        
        return output
        
    }
    
}
