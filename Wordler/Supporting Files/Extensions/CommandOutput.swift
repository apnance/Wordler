//
//  CommandOutput.swift
//  Wordler
//
//  Created by Aaron Nance on 12/13/24.
//

import ConsoleView

extension CommandOutput {
    
    static func emphasize(_ msg: String) -> CommandOutput {
        
        output(msg, overrideFGColor: .systemBlue.pointEightAlpha)
        
    }
    
}
