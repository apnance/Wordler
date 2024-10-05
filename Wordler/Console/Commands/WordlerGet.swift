//
//  WordlerGet.swift
//  Wordler
//
//  Created by Aaron Nance on 10/3/24.
//

import UIKit
import ConsoleView

/// Outputs the date for a given puzzle number.  Output can be redirected to another command.
@available(iOS 15, *)
struct WordlerGet: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.get
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.get
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        var i           = 0
        var arg         = args.elementNum(i)
        var option      = ""
        var contents    = [String]()
        
        /// Advances to next argument returning true unless none found then it returns false.
        func next() -> Bool {
            
            i += 1
            arg = args.elementNum(i)
            
            return arg.isNotEmpty
            
        }
        
        
#warning("Add ability specify range of answers to retrieve")
        
        func output() -> CommandOutput {
            
            var output  = CommandOutput()
            var row     = 0
            
            for content in contents {
                
                let content = content.tidy()
                
                let target = (row % 2 == 0) ? FormatTarget.output : .outputDeemphasized
                
                output += console.screen.format(content + "\n",
                                                target: target,
                                                overrideFGColor: nil)
                // Next
                row += 1
                
            }
            
            return output
            
        }
        
        if arg.type == .option {
            
            option = arg
            
            if !next() {
                
                return output() /*EXIT: Nothing to Do*/
                
            }
            
        }
        
        repeat {
            
            let answers = solver.getFor(arg)
            if answers.count == 0 {
                
                contents.append("\(arg): nothing to get.");
                continue /*CONTINUE*/
                
            }
            
            switch option {
                    
                case "w":
                    
                    contents.append(answers.reduce("\(arg): ") { $0 + " " + $1.word })
                    
                case "d":
                    
                    contents.append(answers.reduce("\(arg): ") { $0 + " " + ($1.date?.simple ?? "")})
                    
                case "n":
                    
                    contents.append(answers.reduce("\(arg): ") { $0 + " " + $1.computedPuzzleNum.description })
                    
                default:
                    
                    contents.append(answers.reduce("\(arg):") { $0 + " " + $1.description + "\n"})
                    
            }
            
        } while next()
        
        return output()
        
    }
    
}
