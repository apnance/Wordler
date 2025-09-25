//
//  WordlerNuke.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import ConsoleView

/// Reverts remembered word list to hard coded list of words from words.wordle.remembered.answers.txt.
@available(iOS 15, *)
struct WordlerNuke: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    static var flags: [Token] = ["Y","N"]
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.nuke
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.nuke
    
    let validationPattern: CommandArgPattern? = Configs.Settings.Console.Commands.Validation.nuke
    
    func process(_ args: [Argument]?) -> CommandOutput {
        
        return yesNo(prompt: """
                                    Nuking cannot be undone and will *DELETE ALL* user-saved puzzles.
                                    
                                    'N' to abort - 'Y' to proceed.
                                    """,
                     yesMsg: CommandOutput.warning("Nuke successful: user saved puzzle(s) deleted."),
                     noMsg: CommandOutput.emphasized("Nuke operation aborted."),
                     args: args,
                     yesCallback: { solver.setRememberedAnswers(revertToFile: true) })
        
    }
    
}

