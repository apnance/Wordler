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

// MARK: - Test
extension Solver {
    
    func test() {
        
        if !Configs.Test.runSuite { return /*EXIT*/ }
        
        func generateAnswerGuess(_ mode: Int) -> [Word] {
            
            switch mode {
                
                case 0: return ["TREAD", "WORSE"]
                    
                case 1:  return ["TORUS", "IRATE"]
                    
                case 2:
                    var answerGuess = [Word]()
                    
                for _ in 0..<Configs.Test.runs {
                        
                        answerGuess.append(allWords.randomElement!.uppercased())
                        answerGuess.append(Configs.Defaults.randomStarter().uppercased())
                        
                    }
                    
                    return answerGuess
                
                default: return Configs.Test.data
                
            }
            
        }
        
        let testData = generateAnswerGuess(2)
        var losers = [Word]()
        var winners = [Word]()
        var totalWinningAttempts = 0
        let totalGames = testData.count / 2
        
        var winningInitialGuess = [Word : Int]()
        var losingInitialGuess  = [Word : Int ]()
        
        for word in Configs.Defaults.initialGuesses {
            
            winningInitialGuess[word]   = 0
            losingInitialGuess[word]    = 0
            
        }
        
        for runNum in 0..<totalGames
        {
            
            resetMatches()
            
            let i = runNum * 2
            let answer = testData[i]
            var guess = testData[i + 1]
            
            let initialGuess = guess
            
            var possibleSolutions: (remaining: [Word : Score], suggested: Word) = ([:], "")
            
            var attempts = 1
            
            repeat {
                
                if guess != answer {
                    
                    attempts += 1
                    
                    let (exc, inc, exa) = analyze(guess: guess, answer: answer)
                    
                    possibleSolutions = updateMatches(exclusionsX: exc,
                                                      inclusionsX: inc,
                                                      exactsX: exa)
                    
                    guess = possibleSolutions.suggested.uppercased()
                    
                }
                
            } while attempts < 6
                    && guess != answer
                    && possibleSolutions.remaining.count > 0
         
            // Victory Check
            let winner = guess == answer
            var outcome = "WIN"
            
            
            if !winner {
                
                losingInitialGuess[initialGuess]! += 1
                
                losers.append("\(answer)<\(attempts)>\(initialGuess)")
                outcome = "LOSS"
                
            } else {

                winningInitialGuess[initialGuess]! += 1
                
                totalWinningAttempts += attempts
                winners.append("\(answer)<\(attempts)>\(initialGuess)")
                
            }
            
            if Configs.Test.echoTestMessages {
                
                print("""
                        
                            =========================
                                 \(answer):\(initialGuess)
                                   - - - - - -
                               \(outcome) in \(attempts) attempts!
                            =========================
                        
                        """)
                
            }
            
        }
        
        let winningPercentage = ((winners.count.double / totalGames.double) * 100).roundTo(1)
        let averageAttemptsToWin = (totalWinningAttempts.double / winners.count.double).roundTo(1)
        
        var initialGuessResults = ""
        
        var initialTab = ""
        for word in winningInitialGuess.keys {
            
            let losses = losingInitialGuess[word]!
            let wins = winningInitialGuess[word]!
            let totals = losses + wins
            let percentWins = wins.percent(of: totals, roundedTo: 1)
            let percentLoss = losses.percent(of: totals, roundedTo: 1)
            
            initialGuessResults += "\(initialTab)\(word) - Win: \(wins) [\(percentWins)]\t Lose: \(losses) [\(percentLoss)]\n"
            
            initialTab = "\t"
        }
        
        print("""
                    
                    =========================
                            Results
                    -------------------------
                
                    \tWinners(\(winners.count)):
                    \t\t\(winners.joined(separator: "\n\t\t\t"))
                    
                           - - - - - -
                    
                    \tLosers(\(losers.count)):
                    \t\t\(losers.joined(separator: "\n\t\t\t"))
                
                           - - - - - -
                
                    Wins:   \(winners.count)/\(totalGames)(\(winningPercentage)%)
                    Losses: (\(losers.count))
                
                    Average Attempts to Win: \(averageAttemptsToWin)
                
                    Initial Guess Success Rate:
                    \(initialGuessResults)
                    =========================
                        
                """)
        
    }
    
    private func analyze(guess: Word,
                         answer: Word) -> (excludes: [Letter],
                                           included: [Letter],
                                           exacts: [Letter]) {
        
        let guess       = guess.uppercased()
        let answer      = answer.uppercased()
        
        let gA          = guess.map{ String($0) } // Guess Array
        let aA          = answer.map{ String($0) } // Answer Array
        
        var excludes    = Array(repeating: "-", count: 5)
        var includes    = Array(repeating: "-", count: 5)
        var exacts      = Array(repeating: "-", count: 5)

        for (i, currentLetter) in gA.enumerated() {
            
            if currentLetter == aA[i] {
                
                exacts[i] = currentLetter
                
            } else if aA.contains(currentLetter) {
                
                includes[i] = currentLetter
                
            } else {
                
                excludes[i] = currentLetter
                
            }
            
        }
        
        return (excludes, includes, exacts)
        
    }
    
}
