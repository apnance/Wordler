//
//  WordlerConsoleConfigurator.swift
//  Wordler
//
//  Created by Aaron Nance on 6/24/24.
//

import UIKit
import APNUtil
import ConsoleView

struct WordlerCommandConfigurator: ConsoleConfigurator {
    
    @discardableResult init(consoleView: ConsoleView, 
                            solver: Solver) {
        
        self.consoleView = consoleView
        self.solver = solver
        
        load()
        
    }
    
    var solver: Solver
    var consoleView: ConsoleView
    
    var commandGroups: [CommandGroup]? { [wordlerCommandGroup] }
    
    var configs: ConsoleViewConfigs? {
        
        var configs = ConsoleViewConfigs()
        
        configs.fgColorPrompt       = Configs.UI.Color.wordleYellow!
        configs.fgColorCommandLine  = Configs.UI.Color.wordleYellow!
        configs.fgColorScreenInput  = Configs.UI.Color.wordleGreen!
        configs.fgColorScreenOutput = Configs.UI.Color.wordleGrayLight!
        
        configs.borderWidth         = Configs.UI.standardBorderWidth
        configs.borderColor         = Configs.UI.Color.wordleGrayDark!.cgColor
        
        configs.bgColor             = Configs.UI.Color.wordleBackgroundGray
        
        configs.fontName            = "Menlo"
        configs.fontSize            = 9
        
        configs.aboutScreen         =     """
                                            Welcome
                                            to
                                            Wordler \("v\(Bundle.appVersion)")
                                            """.fontify(.mini)
        
        configs.fgColorHistoryBarCommand            = Configs.UI.Color.wordleGreen!
        configs.fgColorHistoryBarCommandArgument    = Configs.UI.Color.wordleYellow!.pointSevenAlpha
        configs.bgColorHistoryBarMain               = Configs.UI.Color.wordleGrayDark!.pointSevenAlpha
        configs.bgColorHistoryBarButtons            = Configs.UI.Color.wordleGrayDark!.pointEightAlpha
        
        // tap-to-hide
        configs.shouldHideOnScreenTap = true
        
        // Set shouldMakeCommandFirstResponder = false if you intend to hide console at launch.
        configs.shouldMakeCommandFirstResponder = false
        
        return configs
        
    }
    
    var wordlerCommandGroup: CommandGroup {
        
        return [
                
                Command(token: Configs.Settings.Console.Commands.Tokens.recap,
                        processor: comRecap,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.recap),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.add,
                        processor: comRememberedAdd,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.add),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.last,
                        processor: comLast,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.last),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.rem,
                        processor: comRemembered,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.rem),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.csv,
                        processor: comRememberedCSV,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.csv),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.del,
                        processor: comRememberedDel,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.del),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.gaps,
                        processor: comGaps,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.gaps),
                
                Command(token: Configs.Settings.Console.Commands.Tokens.nuke,
                        processor: comRememberedNuke,
                        category: Configs.Settings.Console.Commands.category,
                        helpText:  Configs.Settings.Console.Commands.HelpText.nuke)
                
            ]
        
        func comLast(_ args:[String]?, console: ConsoleView) -> CommandOutput {
            
            var output  = AttributedString("")
            
            var k       = 1
            
            let arg1    = args.elementNum(0)
            
            if arg1 != "" {
                
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
        
        func comRemembered(args :[String]?, console: ConsoleView) -> CommandOutput {
            
            let arg1 = args.elementNum(0).lowercased()
            
            if arg1 == "count" {
                
                return consoleView.formatCommandOutput("\(solver.rememberedAnswers.count) answers remembered.") /*EXIT*/
                
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
        
        func comRememberedCSV(_:[String]?, console: ConsoleView) -> CommandOutput {
            
            let csv = Array(solver.rememberedAnswers)
                .sorted{ $0.date! < $1.date! }
                .reduce(""){ "\($0)\n\($1.descriptionCSV)"}
            
            printToClipboard(csv)
            
            var atts = consoleView.formatCommandOutput("""
                        \(csv)
                        
                        [Note: above output copied to pasteboard]
                        """)
            
            atts.foregroundColor    = UIColor.lightGray
            
            return atts
            
        }
        
        func comRememberedNuke(_ args:[String]?, console: ConsoleView) -> CommandOutput {
            
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
                    
                    consoleView.registerCommand(Configs.Settings.Console.Commands.Tokens.nuke,
                                                expectingResponse: expectedResponses)
                    
                    commandOutput = """
                                    [Warning] Nuking cannot be undone and will *DELETE ALL* user-saved answers.
                                    
                                    'N' to abort - 'Y' to proceed.
                                    """
                    
            }
            
            return consoleView.formatCommandOutput(commandOutput)
            
        }
        
        func comRememberedDel(_ args:[String]?, console: ConsoleView) -> CommandOutput {
            
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
        
        func comRememberedAdd(_ args:[String]?, console: ConsoleView) -> CommandOutput {
            
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
        
        /// Echoes an ASCII representation of all of missing `ArchivedPuzzle` data.
        /// - Parameter _: does not require or process arguments.
        func comGaps(_:[String]?, console: ConsoleView) -> CommandOutput {
            
            let answerNums  = solver.archivedAnswers.values.sorted{
                ($0.answerNum ?? $0.computedAnswerNum ) < ($1.answerNum ?? $1.computedAnswerNum)
            }.map{ $0.answerNum ?? $0.computedAnswerNum }
            
            let searchRange = 1...Answer.todaysAnswerNum
            
            let output      = GapFinder.describeGaps(in: answerNums,
                                                     usingRange: searchRange)
            
            return consoleView.formatCommandOutput(output)
            
        }
        
        func comRecap(_ args: [String]?, console: ConsoleView) -> CommandOutput {
            
            if let recapText = (consoleView.viewController as? ViewController)?.gameSummaryText {
                
                if recapText.isEmpty {
                    
                    consoleView.format("[Warning] : Nothing to recap yet.", 
                                       target: .outputWarning)
                    
                } else {
                    
                    consoleView.formatCommandOutput(recapText, 
                                                    overrideColor: Configs.UI.Color.wordleYellow)
                    
                }
                
            } else {
                
                consoleView.format("[Error] : Unable to access recap summary.", 
                                   target: .outputWarning)
                
            }
            
        }
        
    }
    
}
