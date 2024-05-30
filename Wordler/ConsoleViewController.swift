//
//  TestViewController.swift
//  Wordler
//
//  Created by Aaron Nance on 5/21/24.
//

import UIKit
import APNUtil
import APNConsoleView

class TestViewController: UIViewController {
    
    @IBOutlet weak var consoleView: APNConsoleView!
    private let solver = Solver.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // HERE...
        // TODO: Clean Up - finish implementing console commands....
        // TODO: Clean Up - rename TestViewConroller, finalize UI for summoning/managing the console view.
        fatalError("HERE!")
        
        consoleView.set(delegate: self)
        
        uiInit()
        
    }
    
    func uiInit() {
        
        consoleView.layer.borderColor = Configs.UI.Color.wordleGrayDark?.cgColor
        consoleView.layer.borderWidth = Configs.UI.standardBorderWidth
        
    }
    
    func comLast(_ args:[String]?) -> CommandOutput {
        
        var output = ""
        
        var k = 1
        if let args = args, 
            args.count > 0 {
            
            let arg1 = args.first!
            
            guard let lastCount = Int(arg1)
            else {
                
                return consoleView.formatCommandOutput("[Error] Invalid argument: '\(arg1)'. Specify Integer count value.]") // EXIT
                
            }
                if lastCount < 1 {
                    
                    return consoleView.formatCommandOutput("[Error] Invalid argument: '\(arg1)'. [Error] specify count argument > 0]]") // EXIT
                }
            
            k = lastCount
            
        }
        
        let lastK = Array(solver.rememberedAnswers).sorted(by: { $0.date! < $1.date! }).last(k)
        
        output += "\nLast \(lastK.count) Remembered Word(s)"
        
        for remembered in lastK {
            
                output += """
                            
                            \t#:\t\(remembered.answerNum ?? -1279)
                            \tWord:\t\(remembered.word.uppercased())
                            \tDate:\t\(remembered.date?.simple ?? "?")
                            """
                
            }
        
        if lastK.count != k {
            output += """
                        
                        
                        Note: Requested(\(k)) > Total(\(lastK.count))
                        """
        }
        
        return consoleView.formatCommandOutput(output)
        
    }
    
    func comRemembered(_:[String]?) -> CommandOutput {
        
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
            
            for word in args {
                
                if solver.delRememberedByWord(word) {
                    
                    output += "\nDeleted Word: \(word.uppercased())"
                    
                }
                
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
            solver.archive(word.uppercased(), confirmAdd: false)
            output += "\nAdded Word: \(word)"
        }
        
        return consoleView.formatCommandOutput(output)
        
    }

    
}

extension TestViewController: APNConsoleViewDelegate {
    
    var commands: [Command] {
        [
            
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
            
            Command(token: Configs.Settings.Console.Commands.Tokens.add,
                    process: comRememberedAdd,
                    category: Configs.Settings.Console.Commands.category,
                    helpText:  Configs.Settings.Console.Commands.HelpText.add),
            
        ]
    }
    
    var configs: APNConsoleViewConfigs? {
        
        var configs = APNConsoleViewConfigs()
        configs.shouldMakeCommandFirstResponder = true
        
        configs.fgColorPrompt       = .red
        configs.fgColorCommandLine  = .red
        configs.fgColorScreenInput  = .yellow
        configs.fgColorScreenOutput = .orange
        
        
        configs.fontName            = "Menlo"
        configs.fontSize            = 9
        
        configs.defaultScreenText = """
                                     ___       __
                                      \\\\  /\\\\  /
                                       \\\\/  \\\\/ ORDLER v\(Bundle.appVersion)
                                     
                                     """
        
        
        return configs
        
    }
    
    
}
