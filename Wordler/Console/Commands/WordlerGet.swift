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
    
    func process(_ args: [String]?) -> CommandOutput {
        
        var arg1    = args.elementNum(0)
        var arg2    = args.elementNum(1)
        
        // Is first arg an option? - Swap if so.
        if arg1.type == .option { (arg1, arg2) = (arg2, arg1) }
        
        let answers     = solver.getFor(arg1)
        var content     = ""
        
        switch arg2 {
                
            case "w":
                
                content = answers.reduce("") { $0 + " " + $1.word }
                
            case "d":
                
                content = answers.reduce("") { $0 + " " + ($1.date?.simple ?? "")}
                
            case "n":
                
                content = answers.reduce("") { $0 + " " + $1.computedPuzzleNum.description }
                
            default:
                
                content = answers.description
                
        }
                
        
        return console.screen.format(content,
                                     target: .output,
                                     overrideFGColor: UIColor.systemBlue)
        
    }
    
}


typealias Argument = String

enum ArgType { case date, puzzlenum, word, option, unknown }
extension Argument {
    
    var type: ArgType {
        
        if Int(self).isNotNil { return .puzzlenum /*EXIT*/ }
        else if Argument.isWord(self, ofLen: 1) {
            return .option /*EXIT*/
        }
        else if Argument.isWord(self, ofLen: 5) {
            return .word /*EXIT*/
        }
        else if self.simpleDateMaybe.isNotNil { return .date /*EXIT*/ }
        else { return .unknown /*EXIT*/ }
        
    }
    
    
    static func isWord(_ word: String, ofLen chars: Int) -> Bool {
        
        let pattern = "^[a-zA-Z]{\(chars)}$"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        let range = NSRange(location: 0, length: word.utf16.count)
        if regex.firstMatch(in: word, options: [], range: range).isNotNil {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}
