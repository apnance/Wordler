//
//  WordlerConsoleConfigurator.swift
//  Wordler
//
//  Created by Aaron Nance on 6/24/24.
//

import UIKit
import APNUtil
import ConsoleView

typealias Colors = Configs.UI.Color

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
        
        configs.fgColorPrompt               = Colors.wordleYellow!
        configs.fgColorCommandLine          = Colors.wordleYellow!
        configs.fgColorScreenInput          = Colors.wordleGreen!
        configs.fgColorScreenOutput         = Colors.wordleGrayLight!
        configs.fgColorScreenOutputNote     = Colors.wordleBlue!
        configs.fgColorScreenOutputWarning  = Colors.wordleYellow!
        
        configs.borderWidth                 = Configs.UI.standardBorderWidth
        configs.borderColor                 = Colors.wordleGrayDark!.cgColor
        
        configs.bgColor                     = Colors.wordleBackgroundGray
        
        configs.fontName                    = "Menlo"
        configs.fontSize                    = 9
        
        configs.aboutScreen                 = """
                                            Welcome
                                            to
                                            Wordler \("v\(Bundle.appVersion)")
                                            """.fontify(.mini)
        
        // Keyboard Accessory View Colors
        let wBGC = Colors.wordleBackgroundGray!
        let wDkG = Colors.wordleGrayDark!
        let wLtG = Colors.wordleGrayLight!
        let wBlu = Colors.wordleBlue!
        let wRed = Colors.wordleRed
        let wYlw = Colors.wordleYellow!
        let wGrn = Colors.wordleGreen!
        let whit = UIColor.white
        configs.cvaBGColor          = wBGC
        configs.cvaHistoryBar       = ColorPalette(bg: .black, fg: wBlu, brdr: wDkG)
        configs.cvaCommandToken     = ColorPalette(bg: .black, fg: wGrn, brdr: wDkG)
        configs.cvaCommandRaw       = ColorPalette(bg: .black, fg: wYlw, brdr: wDkG)
        configs.cvaCommandFlag      = ColorPalette(bg: .black, fg: wRed, brdr: wDkG)
        configs.cvaNumeric          = ColorPalette(bg: .black, fg: whit, brdr: wDkG)
        configs.cvaOperator         = ColorPalette(bg: .black, fg: wLtG, brdr: wDkG)
        configs.cvaQuotes           = ColorPalette(bg: .black, fg: wDkG, brdr: wDkG)
        configs.cvaPound            = ColorPalette(bg: .black, fg: wDkG, brdr: wDkG)
        configs.cvaParenthetical    = ColorPalette(bg: .black, fg: wDkG, brdr: wDkG)
        configs.cvaUndefined        = ColorPalette(bg: .black, fg: wDkG,  brdr: wDkG)
        
        // Suppress Showing Console On App Load
        configs.shouldShowOnLoad                = false
        // Set shouldMakeCommandFirstResponder = false if you intend to hide console at launch.
        configs.shouldMakeCommandFirstResponder = false
        
        // Enable Tap-to-Hide
        configs.shouldHideOnScreenTap           = true
        
        return configs
        
    }
    
}
