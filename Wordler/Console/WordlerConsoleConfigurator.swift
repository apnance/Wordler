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
    var console: Console { consoleView.console }
    
    var commands: [Command]? {
    
        [
            
            WordlerRecap(console: console),
            WordlerAddRemembered(solver: solver, console: console),
            WordlerGetLastRemembered(solver: solver, console: console),
            WordlerRemembered(solver: solver, console: console),
            WordlerOutputCSV(solver: solver, console: console),
            WordlerDelRemembered(solver: solver, console: console),
            WordlerNukeRemembered(solver: solver, console: console)
            
        ]
        
    }
    
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
    
}
