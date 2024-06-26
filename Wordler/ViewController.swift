//
//  ViewController.swift
//  Wordler
//
//  Created by Aaron Nance on 1/11/22.
//

import UIKit
import APNUtil

typealias Row = Int
class ViewController: UIViewController {
    
    // MARK: - Properties
    private let solver = Solver.shared
    private var currentRow = 0
    private var rowToButton = [Row : [WordleButton]]()
    
    private weak var progressIndicator: ProgressIndicator?
        
    // MARK: - Outlets
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var rows: [UIStackView]!
    @IBOutlet weak var popScreenView: UIView!
    @IBOutlet weak var textSummaryView: UITextView!
    @IBOutlet weak var progressIndicatorContainerView: UIView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
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
        
    }
    
    
    // MARK: - Custom Methods
    
    private func uiInit() {
        
        let toStyle: [UIView] = [goButton, clearButton, textView, textField, textSummaryView]
        
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
        
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                             action: #selector(showHidePopUp)))
        popScreenView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(showHidePopUp)))
        
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
        
        uiSetVersion()
        
    }
    
    private func uiSetVersion() {
        
        var formatted = AttributedString("")
        
        let version = "v\(Bundle.appVersion)"
        
        for (i, char) in version.enumerated() {
            
            var att = AttributedString(String(char))
            att.foregroundColor = i % 2 == 0 ? Configs.UI.Color.wordleGray : Configs.UI.Color.wordleGrayLight
            
            formatted.append(att)
            
        }
        
        versionLabel.attributedText = NSAttributedString(formatted)
        
    }
    
    @objc private func dismissKeyboard() { textField.resignFirstResponder() }
    
    private func resetBoard() {
        
        currentRow = 0
        
        solver.resetMatches()
        progressIndicator?.reset()
        
        let starterWord         = solver.getStarterWord()
        textField.text          = starterWord
        textView.text           = ""
        textSummaryView.text    = ""
        
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
    
    @objc private func showHidePopUp() { popScreenView.toggleHidden() }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        uiSyncButtonAndTextField()
        
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
    
    
    /// Syncs the text in the always present/up-to-date textView and the textSummaryView hidden in the 
    private func syncTextSummary() {
        
        let lineFeed = textSummaryView.text.isEmpty ? "" : "\n\n"
        textSummaryView.text += "\(lineFeed)\(textView.text ?? "")"
        
    }
    
    private func check() {
        
        DispatchQueue.main.async {
            
            // victory check
            if self.victoryCheck() { return /*EXIT*/ }
            
            self.textView.text = ""
            
            let validationMessage = self.solver.validate(input: self.textField.text)
            if validationMessage != Configs.successMessage {
                
                self.textView.text = validationMessage
                self.syncTextSummary()
                
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
                
                self.textView.text = "Entry Error: \"\(self.textField.text ?? "-?-")\" - Please Check Your Button States"
                self.syncTextSummary()
                
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
            
            self.textView.text = """
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
                        """
            
            self.syncTextSummary()
            
            if remaining.count == 1 { self.victoryCheck(force: true) }
            
        }
        
    }
    
    @discardableResult private func victoryCheck(force: Bool = false ) -> Bool {
        
        if !force {
            
            for button in self.rowToButton[self.currentRow]! {
                
                if button.toggleState != .exact { return false /*EXIT*/ }
                
            }
            
        }
        
        textView.text = "V-I-C-T-O-R-Y"
        syncTextSummary()
        
        // Set Buttons Green
        let buttons = rowToButton[currentRow]!
        buttons.forEach{ $0.toggle(.exact) }
        
        // Archive
        archiveAnswer()
        
        // Signature
        copySignatureToPasteboard(textField.text!)
        
        return true /*EXIT*/
        
    }
    
    private func archiveAnswer() {
        
        if let  word = self.textField.text?.lowercased(),
                solver.allWords.contains(word) {
            
            solver.archive(word)
            
        }
        
    }
    
    /// Copies a signature to the pasteboard for pasting into summary text
    /// generated by Wordle upon completion of game.
    /// - Parameter word: Winning word.
    private func copySignatureToPasteboard(_ word: Word) {
        
        printToClipboard("""
                                   __       __
                                     \\\\  /\\\\  /
                                      \\\\/  \\\\/
                                   
                                   \(Date().simple)
                                   """)
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
    }
    
}
