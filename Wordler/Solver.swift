//
//  Solver.swift
//  Wordler
//
//  Created by Aaron Nance on 1/11/22.
//

import Foundation
import APNUtil

typealias Score = Int
typealias Word = String
typealias Letter = String
typealias Count = Int

class Solver {
    
    // MARK: - Properties
    
    
    /// Manages archival of `rememberedAnswers`.
    var archivedAnswers: ManagedCollection<Answer> = ManagedCollection.load(file: Configs.Settings.File.archivedAnswers.name,
                                                                            inSubDir: Configs.Settings.File.archivedAnswers.subDir)
    
    static var shared               = Solver()
    private var getCounter          = 0 { didSet { checkGetCount() } }
    
    var allWords: Set<Word> { getAllWords() }
    private var _allWords           = Set<Word>()
    
    /// Set containing a list of all *remembered* `Answer`s for previous puzzles.
    /// - Note: When Wordler solves a puzzle he asks the user to confirm addition of
    /// that word to the archive.  This is how Wordler *remembers* previous answers.
    var rememberedAnswers: Set<Answer>  { getRememberedAnswers() }
    private var _rememberedAnswers  = Set<Answer>()
    
    lazy private var wordHopper     = Set<Word>(allWords)
    
    
    // MARK: - Custom Methods
    /// Helper method for checking that `getWords()` and `getSolutions()` aren't called more
    /// than once each.
    private func checkGetCount() {
        
        let expected = 2
        
        assert( getCounter <= expected,
                "Data initialized more than expected. Expected: \(expected) - Found: \(getCounter)")
        
    }
    
    private func getAllWords() -> Set<Word> {
        
        if !_allWords.isEmpty {
            
            return _allWords /*EXIT*/
            
        }
        
        getCounter += 1
        
        // Load
        let file = (name:"words.wordle", type: "txt")
        
        if let path = Bundle.main.path(forResource: file.name, 
                                       ofType: file.type) {
            
            do {
                
                let text    = try String(contentsOfFile: path).snip() // Snip trailing new line
                
                _allWords   = Set<Word>(text.components(separatedBy: "\n"))
                
            } catch { print("Error reading file: \(path)") }
            
        }
        
        // Validate
        for word in _allWords {
            
            assert(word.count == 5, 
                   "Word \(word) has invalid length of \(word.count)")
            
        }
        
        return _allWords /*EXIT*/
        
    }
    
    //        HERE... Add console mode with help and command line prompt...
            // TODO: Clean Up - add command line mode:
            //      add commands to list remembered answers, delete remembered answer add remembered answer, help,
            // TODO: Clean Up - implement ability to wipe archived words, atleast those not in wrods.wordle.previous.answers.txt
    
    func getLast(_ rememberedCount: Int) -> [Answer] {
        
        var last = [Answer]()
        
        let remembered = Array(_rememberedAnswers).sorted(by: { $0.date! < $1.date! })
        
        return remembered.last(rememberedCount)
        
        
    }
    
    
    /// Attempts to delete the remembered `Answer` with matching `Word`
    /// - Returns: success flag, `true` if word was deleted, `false` otherwise.
    func delRememberedByWord(_ withWord: Word) -> Bool {
        
        let word = withWord.lowercased()
        
        for answer in rememberedAnswers {
            
            if answer.word.lowercased() == word {
                
                if archivedAnswers.delete(answer) {
                    
                    _rememberedAnswers.remove(answer)
                    return true /*EXIT*/
                    
                }
                
            }
            
        }
        
        return false /*EXIT*/
        
    }
    
    /// Attempts to delete the remembered `Answer` with matching `date`
    /// - Returns: success flag, `true` if word(s) was deleted, `false` otherwise.
    func delRememberedByDate(_ date: Date) -> [Word] {
        
        var deleted = [Word]()
        
        for answer in rememberedAnswers {
            
            if answer.date?.simple == date.simple {
                
                if archivedAnswers.delete(answer) {
                    
                    deleted.append(answer.word)
                    _rememberedAnswers.remove(answer)
                    
                }
                
            }
            
        }
        
        return deleted /*EXIT*/
        
    }
    
    // TODO: Clean Up - Factor into sub-funcs
    private func getRememberedAnswers() -> Set<Answer> {
        
        if _rememberedAnswers.isEmpty {         // Load
            
            if archivedAnswers.count > 0 {      // Archived - Updated After Each Win
                
                print("Loading Remembered Answers From Archive:")
                
                for answer in archivedAnswers.values {
                    
                    _rememberedAnswers.insert(answer)
                    
                }
                
            } else {                            // Defaults - Hard-Coded List of Previous Answers
                
                let file = Configs.Settings.File.rememberedAnswers
                
                print("Loading Remembered Answers From File: \(file.name).\(file.type)")
                
                var lines = [String]()
                
                if let path = Bundle.main.path(forResource: file.name, ofType: file.type) {
                    
                    do {
                        
                        let text = try String(contentsOfFile: path).snip() // Snip trailing new line
                        
                        lines = text.components(separatedBy: "\n")
                        
                    } catch { print("Error reading file: \(path)") }
                    
                }
                
                // Trim Header
                var headerRowCount = 0
                
                for line in lines {
                    
                    if line.contains(Configs.Settings.Puzzle.historicalFirstWord) { break /*BREAK*/ }
                    
                    headerRowCount += 1
                    
                }
                
                assert(headerRowCount != lines.count,
                       """
                           Original answer to first Wordle puzzle '\(Configs.Settings.Puzzle.historicalFirstWord)' was not found.
                           Something/s wrong. Check header in \(Configs.Settings.File.rememberedAnswers.name).\(Configs.Settings.File.rememberedAnswers.type).
                           """)
                
                lines.removeFirst(headerRowCount)
                
                // Process Answers
                for line in lines {
                    
                    let data        = line.split(separator: ";")
                    
                    assert(data.count == 3, "\(line) <-- Error Here")
                    
                    let word        = String(data[0])
                    let answerNum   = Int(data[1])
                    let answerDate  = String(data[2]).simpleDate
                    
                    
                    let answer = Answer(managedID: nil,
                                        word: word.uppercased(),
                                        answerNum: answerNum,
                                        date: answerDate)
                    
                    archivedAnswers.add(answer,
                                        allowDuplicates: false,
                                        shouldArchive: false )
                    
                    _rememberedAnswers.insert(answer)
                    
                }
                
                archivedAnswers.save()
                
            }
            
        }
        
        return _rememberedAnswers
        
    }
    
    /// Checks that the specified input is a five letter word contained in the Wordle answer list
    func validate(input: String?) -> String {
        
        if input == nil { return "Nil Input is Invalid." /*EXIT*/ }
        
        if input!.count != 5 { return "Input must be 5 letters not \(input!.count)." }
        
        if !allWords.contains(input!.lowercased()) { return "\(input!) is not contained in Worlde answer list.  Try another 5 letter word." /*EXIT*/ }
        
        return Configs.successMessage
        
    }
    
    
    /// Resets solver - should be called before each new game
    func resetMatches() { wordHopper = Set<Word>(allWords) }
    
    func updateMatches(exclusions: [Letter],
                       inclusions: [Letter],
                       exacts: [Letter]) -> (remaining: [Word : Score],
                                             suggested: Word,
                                             repeatedAnswer: Answer?) {
        
        if wordHopper.count == 0 { resetMatches() }
        
        let exclusions  = exclusions.map{ $0.lowercased() }
        let inclusions  = inclusions.map{ $0.lowercased() }
        let exacts      = exacts.map{ $0.lowercased() }
        
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
        
        return suggestBestFrom(wordHopper)
        
    }
    
    
    /// Returns the best possible starter word for a puzzle  from `allWords`
    func getStarterWord() -> Word {
        
        suggestBestFrom(allWords).suggested.uppercased()
        
    }
    
    /// Considers all words in `words` against the current board, returning the most likely guess.
    private func suggestBestFrom(_ words: Set<Word> ) -> (remaining: [Word : Score],
                                                  suggested: Word,
                                                  repeatedAnswer: Answer?) {
        
        var tally   = [Letter : Int]()
        var scored  = [Word : Int]()
        var best    = (word: "", score: 0)
        
        let rememberedAnswerWords = Set<Word>( rememberedAnswers.map{$0.word} )
        
        // Revert to remembered answers if hopper contains only remembered answers,
        // i.e. you've exhausted the words that have never been answers before.
        let shouldUseRememberedAnswers = words.subtracting(rememberedAnswerWords).count == 0
        
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
            
            if !shouldUseRememberedAnswers
                && rememberedAnswerWords.contains(word) {
                
                continue /*CONTINUE*/
                
            }
            
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
        
        for answer in rememberedAnswers {
            
            if answer.word == best.word {
                
                return (scored, best.word, answer) /*EXIT*/
                
            }
            
        }
        
        return (scored, best.word, nil)
        
    }
    
    private func echoMatchCount() {
        
        if Configs.Test.echoTestMessages {
            
            print("Matching Words: \(wordHopper.count)")
            
        }
        
    }
    
    /// Confirms the user wants to archive the specified `Word` and  if
    /// confirmed archives it.
    /// - Parameter word: winning answer `Word` to archive.
    func archive(_ word: Word, confirmAdd: Bool = true) {
        
        let text: AlertText = (title: "Remember '\(word.uppercased())' As a Previous Winning Answer?",
                               message: """
                                            Click yes to add '\(word)' to the list \
                                            of remembered answers.  This will result \
                                            in '\(word)' being considered last for \
                                            suggestions in future cheat attempts.
                                            """)
        
        let answer = Answer(managedID: nil,
                            word: word.uppercased(),
                            answerNum: nil,
                            date: Date().simple.simpleDate)
        
        var alreadyArchived = false
        for remembered in rememberedAnswers {
            
            if answer.word == remembered.word {
                
                alreadyArchived = true
                break /*BREAK*/
                
            }
            
        }
        
        if !alreadyArchived {
            
            if !confirmAdd { 
                
                let id = self.archivedAnswers.add(answer,
                                                  allowDuplicates: false,
                                                  shouldArchive: true)
                
                self._rememberedAnswers.insert(self.archivedAnswers.entryFor(id)!)
                
            } else {
                Alert.yesno(text,
                            yesHandler: {
                    (UIAlertAction)->()
                    
                    in
                    
                    let id = self.archivedAnswers.add(answer,
                                                      allowDuplicates: false,
                                                      shouldArchive: true)
                    
                    self._rememberedAnswers.insert(self.archivedAnswers.entryFor(id)!) },
                            
                            noHandler: {
                    
                    (UIAlertAction)->()
                    
                    in
                    
                    self._rememberedAnswers.insert(answer)
                })
                
            }
            
        }
        
    }
    
}
