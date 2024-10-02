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
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.add
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.add
    
    func process(_ args: [String]?) -> CommandOutput {
        
        var i = 0
        var output = CommandOutput()
        var screen = console.screen!
        
        repeat {
            
            let word = args.elementNum(i).uppercased()
            let date = args.elementNum(i + 1).simpleDateMaybe
            
            i += date.isNotNil ? 2 : 1
            
            if Solver.validate(word) {
                
                solver.archive(word, date: date, confirmAdd: false)
                output += screen.format("\nWord Remembered: \(word) \(date?.simple ?? "")",
                                        target: .output)
                
            } else {
                
                output += screen.format("\n[ERROR] '\(word)' is not a valid 5 letter word.",
                                        target: .outputWarning)
                
            }
            
        } while args.elementNum(i).isNotEmpty
        
        return output
        
    }
    
    
//    func process(_ args: [String]?) -> CommandOutput {
//        
//        /// Archives buffered `word` if present then resets buffer additionally
//        /// outputs result of processing to `output`.
//        /// - Parameter date: optional date under whicht to archive `word`
//        func processBuffer(date: Date? = nil) {
//            
//            if word.isEmpty {
//            
//                output += "\nNothing left to archive..."
//                
//                return /*EXIT: Nothing to archive*/
//                
//            }
//            
//            // Archive
//            solver.archive(word.uppercased(),
//                           date: date,
//                           confirmAdd: false)
//            
//            // Update Output
//            output += "\nAdded Word: \(word) \(date?.simple ?? "")"
//            
//            // Reset Buffer
//            word = ""
//            
//        }
//        
//        var i = 0
//        var output  = ""
//        var word    = ""
//        
//        while args.elementNum(i).isNotEmpty {
//            
//            let arg = args.elementNum(i)
//            
//            // Date?
//            if let dateArg = arg.simpleDateMaybe {
//                
//                if word.isNotEmpty {
//                    
//                    processBuffer(date: dateArg)
//                    
//                } else {
//                    
//                    output += "\n[ERROR] No word is specified for give date \(arg)"
//                    
//                }
//                
//            // Word?
//            } else {
//                
//                if word.isNotEmpty { processBuffer() }
//                
//                if Solver.validate(arg) {
//                    
//                    word = arg.uppercased()
//                    
//                } else {
//                    
//                    output += "\n[ERROR] \(arg) is not a valid 5 letter word."
//                    
//                }
//                
//            }
//            
//            i += 1 // Next
//            
//        }
//        
//        processBuffer()
//        
//        return console.screen!.formatCommandOutput(output)
//        
//    }
    
    
}

