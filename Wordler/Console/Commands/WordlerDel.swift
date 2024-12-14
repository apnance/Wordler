//
//  WordlerDel.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import ConsoleView

/// Deletes specified word(s) from remembered word list.
@available(iOS 15, *)
struct WordlerDel: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    var commandToken    = Configs.Settings.Console.Commands.Tokens.del
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.del
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        guard let args = args,
              args.count > 0
        else {
            
            return CommandOutput.error(msg: "please specify word(s) to delete.") // EXIT
            
        }
        
        var output = CommandOutput()
        
        if let date = args[0].simpleDateMaybe {
            
            let deleted = solver.delRememberedByDate(date)
            
            if deleted.count > 0 {
                
                output += CommandOutput.warning("deleted words from: \(date.simple)\(deleted.reduce(""){ $0 + "\n*" + $1.uppercased()})")
                
            } else {
                
                output += CommandOutput.error(msg: "no words found for date \(date.simple)")
                
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
                
                output += CommandOutput.warning("deleted word(s): \(matched.asCommaSeperatedString(conjunction: "&"))")
                
            }
            
            if unmatched.count > 0 {
                output += CommandOutput.error(msg: "word(s) not found: \(unmatched.asCommaSeperatedString(conjunction: "&"))")
            }
            
        }
        
        return output
        
    }
    
}

