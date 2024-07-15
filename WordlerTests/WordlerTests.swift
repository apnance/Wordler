//
//  WordlerTests.swift
//  WordlerTests
//
//  Created by Aaron Nance on 1/18/22.
//

import XCTest
@testable import Wordler

class WordlerTests: XCTestCase {
    
    func testLetterFrequency() { letterFrequency() }
    
    func testAnswerNum() {
        
        let sorted = Solver.shared.archivedAnswers.values.sorted{ $0.date! < $1.date! }
        
        for answer in sorted {
            
            let computed    = answer.computedAnswerNum
            let saved       = answer.answerNum!
            
             print("\(answer.word) :: Saved#> \(answer.answerNum ?? -666) <=> \(answer.computedAnswerNum) <Computed#")
            
            XCTAssert(saved == computed, "\(answer.word) :: Answer Nums: Saved: \(saved) - Computed: \(computed)")
            
        }
        
    }
    
}

extension WordlerTests {
    
    private func outcomes(with initialGuesses: [Word], title: String = "Results") -> String {
        
        func analyze(guess: Word,
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
        
        func generateAnswerGuess(_ mode: Int) -> [Word] {
            
            switch mode {
                
            case 0: return ["TREAD", "WORSE"]
                
            case 1:  return ["TORUS", "IRATE"]
                
            case 2:
                var answerGuess = [Word]()
                
                for _ in 0..<Configs.runs {
                    
                    answerGuess.append(Solver.shared.allWords.randomElement()!.uppercased())
                    answerGuess.append(initialGuesses.randomElement!.uppercased())
                    
                }
                
                return answerGuess
                
            default: return Configs.data
                
            }
            
        }
        
        let testData                    = generateAnswerGuess(2)
        var losers                      = [Word]()
        var winners                     = [Word]()
        var totalWinningAttempts        = 0
        let totalGames                  = testData.count / 2
        
        var winningInitialGuess         = [Word : Int]()
        var losingInitialGuess          = [Word : Int ]()
        
        for word in initialGuesses {
            
            winningInitialGuess[word]   = 0
            losingInitialGuess[word]    = 0
            
        }
        
        for runNum in 0..<totalGames
        {
            
            if runNum % Configs.sampleSize == 0 {
                print("\(title) - \(runNum.percent(of: totalGames, roundedTo: 1))% Complete")
                
            }
            
            Solver.shared.resetMatches()
            
            let i = runNum * 2
            let answer = testData[i]
            var guess = testData[i + 1]
            
            let initialGuess = guess
            
            var possibleSolutions: (remaining: [Word : Score],
                                    suggested: Word,
                                    repeatedAnswer: Answer?) = ([:], "", nil)
            
            var attempts = 1
            
            repeat {
                
                if guess != answer {
                    
                    attempts += 1
                    
                    let (exc, inc, exa) = analyze(guess: guess, answer: answer)
                    
                    possibleSolutions = Solver.shared.updateMatches(exclusions: exc,
                                                                    inclusions: inc,
                                                                    exacts: exa)
                    
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
            
            if Configs.echoTestMessages {
                
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
        
//        print("""
//
//                =========================
//                \(title)
//                -------------------------
//
//                \tWinners(\(winners.count)):
//                \t\t\(winners.joined(separator: "\n\t\t\t"))
//
//                       - - - - - -
//
//                \tLosers(\(losers.count)):
//                \t\t\(losers.joined(separator: "\n\t\t\t"))
//
//                       - - - - - -
//
//                Wins:   \(winners.count)/\(totalGames)(\(winningPercentage)%)
//                Losses: (\(losers.count))
//
//                Average Attempts to Win: \(averageAttemptsToWin)
//
//                Initial Guess Success Rate:
//                \(initialGuessResults)
//                =========================
//
//            """)
        
        let result = """
                
                =========================
                \(title)
                -------------------------
                Wins:   \(winners.count)/\(totalGames)(\(winningPercentage)%)
                Losses: (\(losers.count))
            
                Average Attempts to Win: \(averageAttemptsToWin)
            
                Initial Guess Success Rate:
                \(initialGuessResults)
                =========================
                    
            """
        
        //print(result)
        
        return result
        
    }
    
    private func letterFrequency() {
        
        var letterFreq  = [Letter : Count]()
        var wordScore   = [Word : Score]()
        
        letterFreq["A"] = 0
        letterFreq["B"] = 0
        letterFreq["C"] = 0
        letterFreq["D"] = 0
        letterFreq["E"] = 0
        letterFreq["F"] = 0
        letterFreq["G"] = 0
        letterFreq["H"] = 0
        letterFreq["I"] = 0
        letterFreq["J"] = 0
        letterFreq["K"] = 0
        letterFreq["L"] = 0
        letterFreq["M"] = 0
        letterFreq["N"] = 0
        letterFreq["O"] = 0
        letterFreq["P"] = 0
        letterFreq["Q"] = 0
        letterFreq["R"] = 0
        letterFreq["S"] = 0
        letterFreq["T"] = 0
        letterFreq["U"] = 0
        letterFreq["V"] = 0
        letterFreq["W"] = 0
        letterFreq["X"] = 0
        letterFreq["Y"] = 0
        letterFreq["Z"] = 0
        
        let words = Solver.shared.allWords
        
        // Build Freq Dict
        for word in words {
            
            let letters = word.uppercased().map{ String($0) }
            
            for letter in letters {
                
                letterFreq[letter]! += 1
                
            }
            
        }
        
        // Score Words
        for word in words {
            
            let letters = Set<String>(word.uppercased().map{ String($0) })
            
            var score = 0
            
            for letter in letters {
                
                score += letterFreq[letter]!
                
            }
            
            wordScore[word] = score
            
        }
        
        let scores = wordScore.sorted{$0.value < $1.value }.reduce(""){ $0 + "\($1.key): \($1.value)\n"}
        
        print("""
                =========================
                        Results
                -------------------------
                \(scores)
                -------------------------
                Best Words Sorted Ascending
                
                =========================
                """)
        
    }
    
}
