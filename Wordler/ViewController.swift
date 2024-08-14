//
//  ViewController.swift
//  Wordler
//
//  Created by Aaron Nance on 1/11/22.
//

import UIKit
import APNUtil
import ConsoleView

typealias Row = Int
class ViewController: UIViewController {
    
    // MARK: - Properties
    private let solver = Solver.shared
    private var currentRow = 0
    private var rowToButton = [Row : [WordleButton]]()
    public private(set) var gameSummaryText = ""
    
    private weak var progressIndicator: ProgressIndicator?
        
    // MARK: - Outlets
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var thumbnailGameSummary: UITextView!
    @IBOutlet var rows: [UIStackView]!
    @IBOutlet weak var progressIndicatorContainerView: UIView!
    
    @IBOutlet weak var consoleView: ConsoleView!
    
    // MARK: - Actions
    @IBAction func tapButton(_ sender: WordleButton) {
        
        currentRow = sender.row
        
        if isValid(rowNum: currentRow) {
            
            sender.toggle()
            
        }
        
    }
    
    func isValid(rowNum: Int) -> Bool {
        
        if rowNum >= rows.count { return false /*EXIT*/ }
        
        let row = rowToButton[rowNum]!
        
        for button in row {
            
            if button.letter == "" { return false /*EXIT*/ }
            
        }
        
        return true /*EXIT*/
        
    }
    
    @IBAction func tapGo(_ sender: UIButton) {
        
        dismissKeyboard()
        check()
        
    }
    
    @IBAction func tapClear(_ sender: UIButton) { resetBoard() }
    
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiInit()
        resetBoard()
        
        uiSetSplash()
        
        uiInitConsole()
        
    }
    
    
    // MARK: - Custom Methods
    private func uiInit() {
        
        let toStyle: [UIView] = [goButton, clearButton, thumbnailGameSummary, textField]
        
        for view in toStyle {
            
            view.layer.borderColor = Configs.UI.Color.wordleGrayDark?.cgColor
            view.layer.borderWidth = Configs.UI.standardBorderWidth
            
        }
        
        textField.delegate = self
        textField.addTarget(self,
                            action: #selector(ViewController.textFieldDidChange(_:)),
                            for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        thumbnailGameSummary.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                             action: #selector(uiShowConsole)))
        
        // Build rowToButton
        for (rowNum, row) in rows.enumerated() {
            
            for view in row.subviews {
                
                let button = view as! WordleButton
                
                if rowToButton[rowNum] == nil {
                    rowToButton[rowNum] = [WordleButton]()
                }
                
                button.row = rowNum
                
                rowToButton[rowNum]!.append(button)
                
            }
            
        }
        
        // Build Progress Indicator
        progressIndicator = ProgressIndicator.make(targetView: progressIndicatorContainerView,
                                                   totalWordCount: solver.allWords.count)
        
    }
    
    private func uiSetSplash() {
        
        uiSetSummaryText(   """
                            Welcome
                            to
                            Wordler \("v\(Bundle.appVersion)")
                            """.fontify(.mini),
                            shouldAppendToGameSummaryText: false,
                            shouldSyncConsole: true)
        
    }
    
    func uiInitConsole() {
        
        WordlerCommandConfigurator(consoleView: consoleView,
                                   solver: solver)
        
        DataManagerConfigurator(consoleView: consoleView,
                                data: solver)
        
    }
  
    /// Sets text in thumnaileGameSummary and syncs this would consoleView if `shouldSyncConsole` is `true`
    private func uiSetSummaryText(_ text: String,
                                  shouldAppendToGameSummaryText: Bool = true,
                                  shouldSyncConsole: Bool) {
        
        thumbnailGameSummary.text = text
        
        if shouldAppendToGameSummaryText {
            
            gameSummaryText += gameSummaryText.isEmpty ? text : "\n\(text)"
            
        }
        
        if shouldSyncConsole {
            
            let lineFeed = consoleView.getScreenText().isEmpty ? "" : "\n"
            
            consoleView.set(screenText: "\(lineFeed)\(thumbnailGameSummary.text ?? "")",
                            shouldAppend: true)
            
        }
        
    }
    
    private func uiSyncButtonAndTextField() {
        
        var letters = Array(textField.text!)
        
        letters.padTo(finalCount: 5, with: " ")
        
        for colNum in 0...4 {
        
            let letter = String(letters[colNum]).uppercased()
            
            let row = rowToButton[currentRow]!
            let button = row[colNum]
            button.setTitle(letter, for: .normal)
            
            if currentRow > 0 {
                
                let master = (rowToButton[currentRow - 1])![colNum]
                
                if master.letter == letter {
                    
                    button.toggle(master.toggleState)
                    
                }
                
            }
            
        }
        
    }
    
    @objc private func uiShowConsole() {
    
        let showHide: ShowHide = consoleView.isHidden ? .show : .hide
        
        consoleView.showHide(showHide)
        
    }
    
    @objc private func dismissKeyboard() { textField.resignFirstResponder() }
    
    private func resetBoard() {
        
        currentRow = 0
        
        solver.resetMatches()
        progressIndicator?.reset()
        
        let starterWord = solver.getStarterWord()
        textField.text  = starterWord
        
        uiSetSummaryText("", 
                         shouldSyncConsole: false)
        
        gameSummaryText = ""
        
        progressIndicator?.update(word: starterWord,
                                  remaining: solver.allWords.count)
        
        for rowNum in 0...5 {
            
            let toggleState: ToggleState = rowNum == 0 ? .exclude : .blank
            
            let row = rowToButton[rowNum]!
            for button in row {
                
                button.resetTo(toggleState)
                
            }
            
        }
        
        uiSyncButtonAndTextField()
        
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        uiSyncButtonAndTextField()
        
    }
    
    
    /*
     I. Step through row by row:
     
     1. Check each row for victory conditions
     
     if yes:
     a. end
     
     if no:
     a. go to next step
     
     2. Check if row is empty:
     
     if yes:
     a. add suggestion from previous row
     
     if no:
     a. send current row to solver
     
     3. copy state info for matching letters from previous row
     
     4. clear(empty text, set state to blank) all subsquent rows
     
     Repeat 3-6 until victory or have used up 6 guesses
     
     */
    
    private func check() {
        
        DispatchQueue.main.async {
            
            // victory check
            if self.victoryCheck() { return /*EXIT*/ }
            
            self.uiSetSummaryText("",
                                  shouldSyncConsole: false)
            
            let validationMessage = self.solver.validate(input: self.textField.text)
            if validationMessage != Configs.successMessage {
                
                self.uiSetSummaryText(validationMessage,
                                      shouldSyncConsole: true)
                
                return /*EXIT*/
                
            }
            
            let horizSep        = "------------------------------------------"
            var suggested       = ""
            var footnoteMarker  = ""
            var footNote        = ""
            
            var remaining = [Word : Score]()
            
            var possibleSolutions: (remaining: [Word : Score],
                                    suggested: Word,
                                    repeatedAnswer: Answer?) = ([Word : Score](),
                                                                       "",
                                                                       nil)
            
            var exacts      = ["-", "-", "-", "-", "-"]
            var inclusions  = ["-", "-", "-", "-", "-"]
            var exclusions  = ["-", "-", "-", "-", "-"]
            
            for row in 0..<self.rowToButton.count {
                
                let row = self.rowToButton[row]!
                
                for colNum in 0...4 {
                    
                    let button = row[colNum]
                    
                    let letter = button.titleLabel?.text?.uppercased() ?? "-?-"
                    
                    if button.isWrong {         exclusions[colNum] = letter }
                    else if button.isClose {    inclusions[colNum] = letter  }
                    else if button.isExact {    exacts[colNum] = letter  }
                    
                }
                
                possibleSolutions = self.solver.updateMatches(exclusions: exclusions,
                                                              inclusions: inclusions,
                                                              exacts: exacts)
                
                suggested       = possibleSolutions.suggested.uppercased()
                
                // Footnote
                if let repeatedAnswer   = possibleSolutions.repeatedAnswer {
                    footnoteMarker      = "**"
                    footNote            =   """
                                            
                                            \(horizSep)
                                            \(footnoteMarker) Wordle used previously on \(repeatedAnswer.date!.simple)!
                                            """
                    
                    Alert.ok((title: "Cheeky Wordle!?!",
                              message: "Wordle used '\(repeatedAnswer.word)' answer before on \(repeatedAnswer.date!.simple)!"))
                    
                }
                
                remaining           = possibleSolutions.remaining
                
            }
            
            if suggested == "" {
                
                self.uiSetSummaryText("Entry Error: \"\(self.textField.text ?? "-?-")\" - Please Check Your Button States",
                                      shouldSyncConsole: true)
                
                return /*EXIT*/
                
            }
            
            // Advance Current Row
            self.currentRow = self.currentRow < 5 ? self.currentRow + 1 : self.currentRow
            
            // Grab Next Suggestion
            self.textField.text = suggested.uppercased()
            
            // Fill Buttons with Suggested Word Letters
            self.textFieldDidChange(self.textField)
            
            // Update Progress Indicator
            self.progressIndicator?.update(word: suggested, remaining: remaining.count)
            
            var possibles = ""
            
            Array(remaining)
                .sorted{ $0.value > $1.value }
                .map{ "\($0.key.uppercased()):\($0.value) "}
                .forEach{ possibles += $0 }
            
            self.uiSetSummaryText("""
                                --------------------#\(self.currentRow)--------------------
                                  EXACT:\t[ \(exacts.joined(separator: " ][ ")) ]
                                  INEXACT:\t[ \(inclusions.joined(separator: " ][ ")) ]
                                  EXCLUDE:\t[ \(exclusions.joined(separator: " ][ ")) ]
                                 - - - - - - - - - -
                                  SUGGESTION: \(suggested) \(footnoteMarker)
                                 - - - - - - - - - -
                                  CANDIDATES REMAINING(\(remaining.count)):
                                 - - - - -
                                \(possibles)\
                                \(footNote)
                                ------------------------------------------
                                """,
                                  shouldSyncConsole: true)
            
            if remaining.count == 1 { self.victoryCheck(force: true) }
            
        }
        
    }
    
    @discardableResult private func victoryCheck(force: Bool = false ) -> Bool {
        
        if !force {
            
            for button in self.rowToButton[self.currentRow]! {
                
                if button.toggleState != .exact { return false /*EXIT*/ }
                
            }
            
        }
        
        uiSetSummaryText("VICTORY".fontify(.mini),
                         shouldSyncConsole: true)
        
        // Set Buttons Green
        let buttons = rowToButton[currentRow]!
        buttons.forEach{ $0.toggle(.exact) }
        
        // Archive
        archiveAnswer()
        
        return true /*EXIT*/
        
    }
    
    private func archiveAnswer() {
        
        if let  word = self.textField.text?.uppercased(),
                solver.allWords.contains(word) {
            
            solver.archive(word)
            
        }
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
    }
    
}
