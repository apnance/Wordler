//
//  WordlerConsoleConfigurator.swift
//  Wordler
//
//  Created by Aaron Nance on 6/24/24.
//

import UIKit
import APNUtil
import APNConsoleView

struct WordlerCommandConfigurator: ConsoleConfigurator {
    
    @discardableResult init(consoleView: APNConsoleView, solver: Solver) {
        
        self.consoleView = consoleView
        self.solver = solver
        
        load()
        
    }
    
    var consoleView: APNConsoleView
    var solver: Solver
    
    var commandGroups: [CommandGroup] {
        
        [WordlerCommandGroup(consoleView: consoleView,
                             solver: solver)]
        
    }
    
    var configs: ConsoleViewConfigs {
        
        var configs = ConsoleViewConfigs()
        configs.shouldMakeCommandFirstResponder = true
        
        configs.fgColorPrompt       = .red
        configs.fgColorCommandLine  = .red
        configs.fgColorScreenInput  = .yellow
        configs.fgColorScreenOutput = .orange
        
        configs.fontName            = "Menlo"
        configs.fontSize            = 9
        
        configs.aboutScreen = """
                                    #     # ####### ######  ######  #       ####### ######
                                    #  #  # #     # #     # #     # #       #       #     #
                                    #  #  # #     # #     # #     # #       #       #     #
                                    #  #  # #     # ######  #     # #       #####   ######
                                    #  #  # #     # #   #   #     # #       #       #   #
                                    #  #  # #     # #    #  #     # #       #       #    #
                                     ## ##  ####### #     # ######  ####### ####### #     #
                                                                            version \(Bundle.appVersion)
                                 """
        
        // Disable tap-to-hide
        configs.shouldHideOnScreenTap = false
        
        return configs
        
    }
    
    struct WordlerCommandGroup: CommandGroup {
        
        init(consoleView: APNConsoleView, solver: Solver) {
            
            self.consoleView    = consoleView
            self.solver         = solver
            
        }
        
        private var solver: Solver
        private var consoleView: APNConsoleView
        
        var commands: [Command] {
            [
                
                Command(token: Configs.Settings.Console.Commands.Tokens.add,
                        process: comRememberedAdd,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.add),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.last,
                        process: comLast,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.last),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.rem,
                        process: comRemembered,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.rem),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.csv,
                        process: comRememberedCSV,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.csv),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.del,
                        process: comRememberedDel,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.del),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.nuke,
                        process: comRememberedNuke,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.nuke)
                
            ]
        }
        
        
        func comLast(_ args:[String]?) -> CommandOutput {
            
            var output = AttributedString("")
            
            var k = 1
            if let args = args,
               args.count > 0 {
                
                let arg1 = args.first!
                
                guard let lastCount = Int(arg1)
                else {
                    
                    return consoleView.formatCommandOutput("[Error] Invalid argument: '\(arg1)'. Specify Integer count value.") // EXIT
                    
                }
                
                if lastCount < 1 {
                    
                    return consoleView.formatCommandOutput("[Error] Invalid argument: '\(arg1)'. [Error] specify count argument > 0") // EXIT
                }
                
                k = lastCount
                
            }
            
            let lastK = Array(solver.rememberedAnswers).sorted(by: { $0.date! < $1.date! }).last(k)
            
            output += consoleView.formatCommandOutput("\nLast \(lastK.count) Remembered Word(s)")
            
            for (i, remembered) in lastK.enumerated() {
                
                let rowColor =  (i % 2 == 0)
                ? consoleView.configs.fgColorScreenOutput.halfAlpha
                : consoleView.configs.fgColorScreenOutput.pointEightAlpha
                
                let word = consoleView.formatCommandOutput("""
                                                        
                                                       \t   #: \(remembered.answerNumDescription)
                                                       \tWord: \(remembered.word.uppercased())
                                                       \tDate: \(remembered.date?.simple ?? "?")
                                                       """,
                                                           overrideColor: rowColor)
                
                output += word
                
            }
            
            if lastK.count != k {
                
                output += consoleView.formatCommandOutput("""
                        
                        
                        Note: Requested(\(k)) > Total(\(lastK.count))
                        """)
                
            }
            
            return output
            
        }
        
        func comRemembered(args :[String]?) -> CommandOutput {
            
            if let args = args,
               args.count > 0 {
                
                let arg1 = args.first!.uppercased()
                
                if arg1 == "count" {
                    
                    return consoleView.formatCommandOutput("\(solver.rememberedAnswers.count) answers remembered.") /*EXIT*/
                    
                }
                
            }
            
            
            var remembered = Array(solver.rememberedAnswers)
                .sorted{ $0.date! < $1.date! }
                .reduce(""){ "\($0)\n\($1.description)"}
            
            remembered = remembered.replacingOccurrences(of: "on ", with: "")
            remembered = remembered.replacingOccurrences(of: " ", with: "\t")
            
            var atts                = consoleView.formatCommandOutput(remembered)
            atts.foregroundColor    = UIColor.lightGray
            
            return atts
            
        }
        
        func comRememberedCSV(_:[String]?) -> CommandOutput {
            
            var remembered = Array(solver.rememberedAnswers)
                .sorted{ $0.date! < $1.date! }
                .reduce(""){ "\($0)\n\($1.description)"}
            
            // Format .CSV
            remembered              = remembered.replacingOccurrences(of: "on ", with: "")
            remembered              = remembered.replacingOccurrences(of: " ", with: "\t")
            
            printToClipboard(remembered)
            
            remembered              = ".csv copied to pasteboard\n\(remembered)"
            
            var atts                = consoleView.formatCommandOutput(remembered)
            atts.foregroundColor    = UIColor.lightGray
            
            return atts
            
        }
        
        func comRememberedNuke(_ args:[String]?) -> CommandOutput {
            
            var commandOutput = ""
            let expectedResponses = ["Y","N"]
            
            if let arg1 = args?.first {
                
                
                switch arg1 {
                    case "Y":
                        
                        let startCount  = solver.archivedAnswers.count
                        solver.setRememberedAnswers(revertToFile: true)
                        let deleteCount = startCount - solver.archivedAnswers.count
                        
                        commandOutput = "Nuke successful: \(deleteCount) user saved answers deleted."
                        
                    default:
                        
                        commandOutput = "Nuke operation aborted."
                        
                        
                }
                
            } else {
                
                consoleView.registerCommand(Configs.Settings.Console.Commands.Tokens.nuke,
                                            expectingResponse: expectedResponses)
                
                commandOutput = """
                            [Warning] Nuking cannot be undone and will *DELETE ALL* user-saved answers.
                            
                            'N' to abort - 'Y' to proceed.
                            """
                
            }
            
            return consoleView.formatCommandOutput(commandOutput)
            
        }
        
        func comRememberedDel(_ args:[String]?) -> CommandOutput {
            
            guard let args = args,
                  args.count > 0
            else {
                
                return consoleView.formatCommandOutput("Please specify word(s) to delete.") /*EXIT*/
                
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
            
            return consoleView.formatCommandOutput(output)
            
        }
        
        func comRememberedAdd(_ args:[String]?) -> CommandOutput {
            
            guard let args = args,
                  args.count > 0
            else {
                
                return consoleView.formatCommandOutput("\n[ERROR] Please specify valid 5 letter word(s) to add.") /*EXIT*/
                
            }
            
            var output  = ""
            var words = [Word]()
            
            for arg in args {
                
                if arg.count == 5 {
                    
                    words.append(arg)
                    
                } else {
                    
                    output += "\n[ERROR] \(arg) is not a valid 5 letter word."
                    
                }
                
            }
            
            for word in words {
                
                let word = word.uppercased()
                solver.archive(word, confirmAdd: false)
                output += "\nAdded Word: \(word)"
                
            }
            
            return consoleView.formatCommandOutput(output)
            
        }
        
    }
    
}
