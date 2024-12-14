//
//  CommandOutput.swift
//  Wordler
//
//  Created by Aaron Nance on 12/13/24.
//

import ConsoleView

// TODO: Clean Up - Move to ConsoleView?
extension CommandOutput {
    
    /// Creates a simple `CommandOutput` with newline(s) formatted w/ output
    /// settings(i.e. same font settings)
    static func newLines(_ n: Int = 1) -> CommandOutput {
        
        output(String(String(repeating: "\n", count: n)))
        
    }
    
    
    /// Formats `CommandOutput` for use as a note.  Specify `newLines` > 0
    /// to render newlines before note.
    static func note(_ msg: String, newLines n: Int = 0) -> CommandOutput {
        
        var out = newLines(n)
        out += output("[Note] \(msg)",
                      overrideFGColor: Configs.UI.Color.wordleBlue)
        
        return out
        
    }
    
}
