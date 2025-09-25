//
//  WordlerLast.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import UIKit
import ConsoleView

/// Returns a list of last `n` words added to remembered word list.
@available(iOS 15, *)
struct WordlerLast: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    static var flags: [Token] = []
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.last
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.last
    
    let validationPattern: CommandArgPattern? = Configs.Settings.Console.Commands.Validation.last
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        var output      = CommandOutput.empty
        var k           = 1
        let arg1        = args.elementNum(0)
        
        if arg1 != "" {
            
            guard let lastCount = Int(arg1)
            else {
                
                return CommandOutput.error(msg: "invalid argument '\(arg1)'. Specify an integer count value.") // EXIT
                
            }
            
            if lastCount < 1 {
                
                return CommandOutput.error(msg: "specify count > 0.") // EXIT
                
            }
            
            k = lastCount
            
        }
        
        let lastK = Array(solver.rememberedAnswers).sorted(by: { $0.date! < $1.date! }).last(k)
        
        let header =    lastK.count > 1
                        ? "Last \(lastK.count) remembered words:"
                        : "Last remembered word:"
        
        output += CommandOutput.output(header)
        
        for (i, remembered) in lastK.enumerated() {
            
            output += CommandOutput.output("""
                                                    
                                              #: \(remembered.answerNumDescription)
                                           Word: \(remembered.word.uppercased())
                                           Date: \(remembered.date?.simple ?? "?")
                                           """,
                                           overrideFGColor: Configs.UI.Color.row(i))
            
        }
        
        if lastK.count != k {
            
            output += CommandOutput.note("requested(\(k)) > total(\(lastK.count))",
                                         newLines: 2)
            
        }
        
        return output
        
    }
    
}

