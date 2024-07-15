//
//  Configs.swift
//  Wordler
//
//  Created by Aaron Nance on 1/12/22.
//

import UIKit

struct Configs {
    
    static var successMessage = "Input is Valid."
    
    struct Settings {
        
        struct Puzzle {
            
            /// The answer to the very first Wordle puzzle.
            static let historicalFirstWord = "CIGAR"
            static var historicalFirstDate: Date = "06/19/21".simpleDate
            
        }
        
        struct Console {
            
            struct Commands {
                
                static var category = "WRDLR"
                
                struct Tokens {
                    
                    static var add  = "add"
                    static var last = "last"
                    static var rem  = "rem"
                    static var csv  = "csv"
                    static var del  = "del"
                    static var nuke = "nuke"
                    
                }
                
                struct HelpText {
                    
                    static var add  = """
                                        Attemps to add the specified word(s) to remembered words list.
                                        \tUsage:
                                        \t* 'add BLANK GONGS TITAN' adds words BLANK, GONGS, and TITAN
                                        \t  to rememered words list.
                                        """
                    
                    static var last = """
                                        Echoes last chronological answer(s).
                                        \tUsage:
                                        \t* 'last' echoes last answer "remembered."
                                        \t* 'last 5' echoes last 5 answers "remembered."
                                        """
                    
                    static var rem  = """
                                        Echoes remembered commands.
                                        \t Usage:
                                        \t* 'rem' echoes all "remembered"(i.e. answers to past World puzzles)
                                        \t  answers to screen.
                                        \t* 'rem count' echoes count of all "remembered".
                                        """
                    
                    static var csv  = "Formats remembered answer as CSV and copies to pasteboard."
                    
                    static var del  = """
                                        Attemps to delete the specified word from remembered words list.
                                        \tUsage:
                                        \t* 'del TRUCK TRIPS ZONKS' attempts to delete words TRUCK
                                        \t  TRIPS and ZONKS from remembered words.
                                        \t* 'del 05-23-12' attempts to delete all words added on 05-23-12
                                        """
                    
                    static var nuke =   "**CAUTION** this command *deletes all* user saved answers."
                    
                }
                
            }
            
        }
        
        struct File {
            
            static let archivedAnswers      = (name: "Answers",
                                               subDir: "Data")
            static let rememberedAnswers    = (name:"words.wordle.remembered.answers",
                                               type: "txt")
            
        }
        
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
