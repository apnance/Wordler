//
//  Solver.swift
//  Wordler
//
//  Created by Aaron Nance on 1/11/22.
//

import Foundation

typealias Score = Int
typealias Word = String
typealias Letter = String

class Solver {
    
    // MARK: - Properties
    static var shared = Solver()
    private var getCounter = 0 { didSet { checkGetCount() } }
    
    var allWords: [Word] { getWords() }
    private var _allWords = [Word]()
    
    lazy private var wordHopper = Set<Word>(allWords)
    
    
    // MARK: - Custom Methods
    /// Helper method for checking that `getGords()` and `getSolutions()` aren't called more
    /// than once each.
    private func checkGetCount() {
        
        let expected = 2
        
        assert( getCounter <= expected,
                "Data initialized more than expected. Expected: \(expected) - Found: \(getCounter)")
        
    }
    
    private func getWords() -> [Word] {
        
        if !_allWords.isEmpty {
            
            return _allWords /*EXIT*/
            
        }
        
        getCounter += 1
        
        let file = (name:"words.wordle", type: "txt")
        
        if let path = Bundle.main.path(forResource: file.name, ofType: file.type) {
            
            do {
                
                let text = try String(contentsOfFile: path).snip() // Snip trailing new line
                
                _allWords = text.components(separatedBy: "\n")
                
            } catch { print("Error reading file: \(path)") }
            
        }
        
        // Validate
        for word in _allWords {
            
            assert(word.count == 5, "Word\(word) has invalid length of \(word.count)")

        }
        
        return _allWords /*EXIT*/
        
    }
    
    func resetMatches() {
        
        wordHopper = Set<Word>(allWords)
        
    }
    
    // TODO: Clean Up - remove -X postfix from params
    func updateMatches(exclusionsX: [Letter],
                       inclusionsX: [Letter],
                       exactsX: [Letter]) -> (remaining: [Word : Score], suggested: Word) {
        
        if wordHopper.count == 0 { resetMatches() }
        
        let exclusions  = exclusionsX.map{ $0.lowercased() }
        let inclusions  = inclusionsX.map{ $0.lowercased() }
        let exacts      = exactsX.map{ $0.lowercased() }
        
        // Exacts - Right Letter, Right Spot
        /// exclude words that don't have letters at expected postions
        var exact = [Int : Letter]()
        
        for (i, letter) in exacts.enumerated() {
            
            if letter.isEmpty { continue }
            else { exact[i] = letter }
            
        }
        
        for (i, letter) in exacts.enumerated() {
            
            if letter == "-" { continue /*CONTINUE*/ }
            
            echoMatchCount()
            
            for word in wordHopper {
                                
                let letters = word.toArray()
                
                if letters[i] != letter {
                    
                    wordHopper.remove(word)
                    
                }
                
            }
            
            echoMatchCount()
            
        }
        
        // Exclusions - Wrong Letter
        for (i, exclude) in exclusions.enumerated() {
            
            if exclude == "-" { continue /*CONTINUE*/ }
            
            echoMatchCount()

            let removeAll = !inclusions.contains(exclude) && !exacts.contains(exclude)
            
            
            for word in wordHopper {
    
                let letters = word.map{ String($0) }
                
                if removeAll && letters.contains(exclude) {
                    
                    wordHopper.remove(word)
                    
                } else if letters[i] == exclude {
                    
                    wordHopper.remove(word)
                    
                }
                
            }
            
            echoMatchCount()
            
        }
        
        // Inclusions - Right Letter, Wrong Spot
        for (i, letter) in inclusions.enumerated() {
            
            if letter == "-" { continue /*CONTINUE*/ }
            
            echoMatchCount()
            
            for word in wordHopper {
                
                if !word.contains(letter) {
                    
                    wordHopper.remove(word)
                    
                } else {
                    
                    let letters = word.map{ String($0) }
                    
                    if letters[i] == letter {
                        
                        wordHopper.remove(word)
                        
                    }
                    
                }
                
            }
            
            echoMatchCount()
            
        }
        
        return suggestBestFrom(Array(wordHopper))
        
    }
    
    private func suggestBestFrom(_ words: [Word] ) -> (remaining: [Word : Score], suggested: Word) {
        
        var tally   = [Letter : Int]()
        var scored  = [Word : Int]()
        var best    = (word: "", score: 0)
        
        // Build Tally
        for word in words {
            
            let letters = word.toArray()
            
            for letter in letters {
                
                if tally[letter] == nil {
                    
                    tally[letter] = 1
                    
                } else {
                    
                    tally[letter]! += 1
                    
                }
                
            }
            
        }
        
        // Score Words Against Tally
        for word in words {
            
            var score = 0
            
            // De-Dupe Word Letters
            let letters = Set<Letter>(word.toArray())
            
            for letter in letters {
                
                score += tally[letter]!
                
            }
            
            scored[word] = score
            
            if score > best.score {
                best.word   = word
                best.score  = score
            }
            
        }
        
        return (scored, best.word)
        
    }
    
    private func echoMatchCount() {
        
        if Configs.Test.echoTestMessages {
            
            print("Matching Words: \(wordHopper.count)")
            
        }
    }
    
}
