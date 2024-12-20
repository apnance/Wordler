//
//  WordlerConsoleConfigurator.swift
//  Wordler
//
//  Created by Aaron Nance on 6/24/24.
//

import UIKit
import APNUtil
import ConsoleView

struct WordlerConsoleConfigurator: ConsoleConfigurator {
    
    @discardableResult init(solver: Solver) {
        
        self.solver         = solver
        
        load()
        
    }
    
    var solver: Solver
    
    var commands: [Command]? {
    
        [
            
            WordlerRecap(),
            WordlerDict(solver: solver),
            WordlerGet(solver: solver),
            WordlerAdd(solver: solver),
            WordlerDel(solver: solver),
            WordlerLast(solver: solver),
            WordlerRem(solver: solver),
            WordlerCSV(solver: solver),
            WordlerNuke(solver: solver)
            
        ]
        
    }
    
    var configs: ConsoleViewConfigs? {
        
        var configs = ConsoleViewConfigs()
        
        configs.fgColorPrompt               = Configs.UI.Color.wordleYellow!
        configs.fgColorCommandLine          = Configs.UI.Color.wordleYellow!
        configs.fgColorScreenInput          = Configs.UI.Color.wordleGreen!
        configs.fgColorScreenOutput         = Configs.UI.Color.wordleGrayLight!
        configs.fgColorScreenOutputNote     = Configs.UI.Color.wordleBlue!
        configs.fgColorScreenOutputWarning  = Configs.UI.Color.wordleYellow!
        
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
