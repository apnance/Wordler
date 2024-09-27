//
//  WordlerNukeRemembered.swift
//  Wordler
//
//  Created by Aaron Nance on 9/26/24.
//

import ConsoleView

// TODO: Clean Up - add comment
@available(iOS 15, *)
struct WordlerNukeRemembered: Command {
    
    var solver: Solver
    
    // - MARK: Command Requirements
    var console: Console
    
    var commandToken    = Configs.Settings.Console.Commands.Tokens.nuke
    
    var isGreedy        = false
    
    var category        = Configs.Settings.Console.Commands.category
    
    var helpText        = Configs.Settings.Console.Commands.HelpText.nuke
    
    func process(_ args: [String]?) -> CommandOutput {
        
        var commandOutput       = ""
        let expectedResponses   = ["Y","N"]
        let response            = args.elementNum(0)
        
        switch response {
                
            case "Y":
                
                let startCount  = solver.archivedAnswers.count
                solver.setRememberedAnswers(revertToFile: true)
                let deleteCount = startCount - solver.archivedAnswers.count
                
                commandOutput = "Nuke successful: \(deleteCount) user saved answers deleted."
                
            case "N":
                
                commandOutput   = "Nuke operation aborted."
                
            default:
                
                console.registerCommand(Configs.Settings.Console.Commands.Tokens.nuke,
                                        expectingResponse: expectedResponses)
                
                commandOutput = """
                                [Warning] Nuking cannot be undone and will *DELETE ALL* user-saved answers.
                                
                                'N' to abort - 'Y' to proceed.
                                """
                
        }
        
        return console.screen.formatCommandOutput(commandOutput)
        
    }
    
}

