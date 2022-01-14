//
//  Configs.swift
//  Wordler
//
//  Created by Aaron Nance on 1/12/22.
//

import Foundation

struct Configs {
    
    struct Defaults {
        
        static func randomStarter() -> Word {
            
            ["REACT",
             "ADIEU",
             "SIRED",
             "TEARS",
             "ALONE",
             "ARISE",
             "CREAM",
             "ATONE",
             "IRATE",
             "CREAM",
             "SNARE",
             "CREAM",
             "WORSE",
             "ANIME"].randomElement!
            
        }
        
    }
    
    struct Test {
        
        static var echoTestMessages = false
        
    }
    
    
}
