//
//  Configs.swift
//  Wordler
//
//  Created by Aaron Nance on 1/12/22.
//

import UIKit

struct Configs {
    
    static var successMessage = "Input is Valid."
    
    struct Defaults {
        
        static func randomStarter() -> Word { initialGuesses.randomElement! }
        
        static var initialGuesses = ["SANER",    // Frequency Score: 4355
                                     "RENAL",    // Frequency Score: 4405
                                     "LEARN",    // Frequency Score: 4405
                                     "ARISE",    // Frequency Score: 4451
                                     "RAISE",    // Frequency Score: 4451
                                     "STARE",    // Frequency Score: 4509
                                     "IRATE",    // Frequency Score: 4511
                                     "AROSE",    // Frequency Score: 4534
                                     "ALERT",    // Frequency Score: 4559
                                     "LATER",    // Frequency Score: 4559
                                     "ALTER"]    // Frequency Score: 4559
        
    }
    
    struct UI {
        
        static var standardBorderWidth = 2.0
        
        struct Color {
            
            static let wordleGray           = UIColor(named: "WordleGray")
            static let wordleGrayLight      = UIColor(named: "WordleGrayLight")
            static let wordleGrayDark       = UIColor(named: "WordleGrayDark")
            static let wordleGreen          = UIColor(named: "WordleGreen")
            static let wordleYellow         = UIColor(named: "WordleYellow")
            static let wordleBackgroundGray = UIColor(named: "WordleBackgroundGray")
            
        }
        
    }
    
    struct Test { static var echoTestMessages = false }
    
}
