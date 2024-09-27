//
//  WorlderLast.swift
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
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.last
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.last
    
    func process(_ args: [String]?) -> CommandOutput {
        
        let consoleView = console.screen!
        
        var output: CommandProcessorOutput = ("", AttributedString(""))
        var k           = 1
        let arg1        = args.elementNum(0)
        
        if arg1 != "" {
            
            guard let lastCount = Int(arg1)
            else {
                
                return consoleView.formatCommandOutput("[Error] Invalid argument: '\(arg1)'. Specify Integer count value.") // EXIT
                
            }
            
            if lastCount < 1 {
                
                return consoleView.formatCommandOutput("[Error] Invalid argument: '\(arg1)'. [Error] specify count argument > 0") // EXIT
            }
            
            k = lastCount
            
        }
        
        let lastK = Array(solver.rememberedAnswers).sorted(by: { $0.date! < $1.date! }).last(k)
        
        output += consoleView.formatCommandOutput("\nLast \(lastK.count) Remembered Word(s)")
        
        for (i, remembered) in lastK.enumerated() {
            
            let rowColor =  (i % 2 == 0)
            ? consoleView.configs.fgColorScreenOutput.halfAlpha
            : consoleView.configs.fgColorScreenOutput.pointEightAlpha
            
            let word = consoleView.formatCommandOutput("""
                                                    
                                                   \t   #: \(remembered.answerNumDescription)
                                                   \tWord: \(remembered.word.uppercased())
                                                   \tDate: \(remembered.date?.simple ?? "?")
                                                   """,
                                                       overrideColor: rowColor)
            
            output += word
            
        }
        
        if lastK.count != k {
            
            output += consoleView.formatCommandOutput("""
                    
                    
                    Note: Requested(\(k)) > Total(\(lastK.count))
                    """)
            
        }
        
        return output
        
    }
}

