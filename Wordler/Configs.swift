//
//  Configs.swift
//  Wordler
//
//  Created by Aaron Nance on 1/12/22.
//

import Foundation

struct Configs {
    
    struct Defaults {
        
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
        
        static func randomStarter() -> Word {
            
            initialGuesses.randomElement!
            
        }
        
    }
    
    struct Test {
        
        static var echoTestMessages = false
        
        static let runs             = 100
        static let sampleSize: Int  = runs / 10
        
        static func getTestCouplet(_ i: Int) -> (answer: Word, firstGuess: Word)? {
            
            let i = i * 2
            
            if i + 1 <= data.lastUsableIndex {
                
                return (data[i], data[i + 1])
                
            }
            
            return nil /*EXIT*/
            
        }
        
        static let data =
        [
        "SALAD","CREAM",
        "GROAN","ANIME",
        "STONE","CREAM",
        "SNIFF","CREAM",
        "RANDY","IRATE",
        "CRAMP","SIRED",
        "POESY","TEARS",
        "CHOSE","ADIEU",
        "SLASH","SIRED",
        "DERBY","CREAM",
        "TORUS","CREAM",
        "DRONE","CREAM",
        "BANJO","WORSE",
        "PALSY","ALONE",
        "CHEAP","SIRED",
        "PLATE","ADIEU",
        "ROUGE","TEARS",
        "MAJOR","CREAM",
        "SLOSH","SNARE",
        "STAKE","WORSE",
        "CLICK","WORSE",
        "ATTIC","ANIME",
        "AGATE","ARISE",
        "FATAL","SNARE",
        "POPPY","IRATE",
        "BLISS","ANIME",
        "SPASM","ALONE",
        "CURVE","SIRED",
        "SATYR","WORSE",
        "PANIC","SIRED",
        "EQUIP","ATONE",
        "HERON","CREAM",
        "INEPT","REACT",
        "CUMIN","ALONE",
        "FICUS","REACT",
        "REUSE","IRATE",
        "CHEER","REACT",
        "SCRUB","IRATE",
        "BIRCH","ADIEU",
        "OBESE","CREAM",
        "TAPER","REACT",
        "PUPPY","ARISE",
        "STALL","CREAM",
        "ALARM","ANIME",
        "SWEAT","SIRED",
        "POLYP","CREAM",
        "UNCUT","CREAM",
        "SLURP","TEARS",
        "SLOTH","CREAM",
        "SOWER","SNARE",
        "TORSO","SNARE",
        "FOUND","IRATE",
        "DEIGN","ALONE",
        "CHAMP","ALONE",
        "BRAID","SNARE",
        "ABBEY","SIRED",
        "PLEAT","CREAM",
        "RODEO","CREAM",
        "GUILE","TEARS",
        "THIEF","ALONE",
        "FRISK","ANIME",
        "ROUND","ARISE",
        "COBRA","REACT",
        "BASTE","ARISE",
        "RETCH","CREAM",
        "SPOOK","ANIME",
        "SMELT","TEARS",
        "WORLD","TEARS",
        "STYLE","CREAM",
        "KNOWN","SNARE",
        "MAFIA","WORSE",
        "GRIMY","REACT",
        "BUNNY","ATONE",
        "JELLY","ADIEU",
        "TOWER","ALONE",
        "EXTOL","ANIME",
        "PINCH","TEARS",
        "WHICH","WORSE",
        "MINIM","ATONE",
        "REBEL","IRATE",
        "RATTY","WORSE",
        "BROTH","SIRED",
        "ORGAN","SIRED",
        "TRUTH","WORSE",
        "CLANK","ARISE",
        "JUROR","CREAM",
        "SPELT","REACT",
        "SHRUG","CREAM",
        "HILLY","SIRED",
        "FRISK","ADIEU",
        "FLAKY","SNARE",
        "JOKER","CREAM",
        "SMITE","IRATE",
        "DEBIT","CREAM",
        "MANGO","IRATE",
        "IMBUE","CREAM",
        "ATTIC","IRATE",
        "SWEAR","IRATE",
        "HONOR","ARISE",
        "SHONE","ATONE"
        ]
        
    }
    
    
    
}
