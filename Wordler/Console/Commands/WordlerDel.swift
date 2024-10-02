//
//  WordlerDelRemembered.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import ConsoleView

// TODO: Clean Up - add comment
@available(iOS 15, *)
struct WordlerDel: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.del
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.del
    
    func process(_ args: [String]?) -> CommandOutput {
        
        guard let args = args,
              args.count > 0
        else {
            
            return console.screen.formatCommandOutput("Please specify word(s) to delete.") /*EXIT*/
            
        }
        
        var output = ""
        
        if let date = args[0].simpleDateMaybe {
            
            let deleted = solver.delRememberedByDate(date)
            
            if deleted.count > 0 {
                
                output += "\nDeleted Words From: \(date.simple)\(deleted.reduce(""){ $0 + "\n\t*" + $1.uppercased()})"
                
            } else {
                
                output += "\n[ERROR] No words found for date \(date.simple)"
                
            }
            
        } else {
            
            var deleted = Array(repeating: false, count: args.count)
            
            for (i, word) in args.enumerated() {
                
                if solver.delRememberedByWord(word) {
                    
                    deleted[i] = true
                    
                }
                
            }
            
            
            var (matched, unmatched) = ([String](), [String]())
            
            for (i, wasDeleted) in deleted.enumerated() {
                
                if wasDeleted { matched.append(args[i]) }
                else {          unmatched.append(args[i]) }
                
            }
            
            if matched.count > 0 {
                
                output += "\nDeleted Word(s): \(matched.asCommaSeperatedString(conjunction: "&"))"
                
            }
            
            if unmatched.count > 0 {
                output += "\n[ERROR] Word(s) not found: \(unmatched.asCommaSeperatedString(conjunction: "&"))"
            }
            
        }
        
        return console.screen.formatCommandOutput(output)
        
    }
    
}

