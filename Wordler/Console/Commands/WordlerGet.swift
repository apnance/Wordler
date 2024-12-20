//
//  WordlerGet.swift
//  Wordler
//
//  Created by Aaron Nance on 10/3/24.
//

import UIKit
import ConsoleView

/// Outputs the puzzle data for a given puzzle number, date, or word.  Output can be redirected to another command.
///
/// - note: AltonGet.swift is a mirror of this functionality.  Any changes to this file might benefit that one as well.
@available(iOS 15, *)
struct WordlerGet: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
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
        
        /// Formats content as `CommandOutput`
        func output() -> CommandOutput {
            
            var output  = CommandOutput()
            
            for (i, content) in contents.enumerated() {
                
                let content = content.tidy() + "\n"
                
                output += CommandOutput.output(content,
                                               overrideFGColor: Configs.UI.Color.row(i))
                
            }
            
            return output // EXIT
            
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
                    
                case "c":
                    
                    contents.append("\(arg): \(answers.count) puzzle(s)")
                    
                default:
                    
                    contents.append(answers.reduce("\(arg):") { $0 + " " + $1.description + "\n"})
                    
            }
            
        } while next()
        
        return output()
        
    }
    
}
