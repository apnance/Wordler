//
//  Configs.swift
//  Wordler
//
//  Created by Aaron Nance on 1/12/22.
//

import Foundation

struct Configs {
    
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
    
    struct Test { static var echoTestMessages = false }
    
}
