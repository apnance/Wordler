//
//  ViewController.swift
//  Wordler
//
//  Created by Aaron Nance on 1/11/22.
//

import UIKit
import APNUtils

typealias Row = Int
class ViewController: UIViewController {

    // MARK: - Properties
    private let solver = Solver.shared
    private var currentRow = 0
    private var rowToButton = [Row : [UIButton]]()
    private var goButton: UIButton { rowToButton[currentRow]![5] }
    
    
    // MARK: - Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var rows: [UIStackView]!
    
    
    // MARK: - Actions
    @IBAction func tapButton(_ sender: WordleButton) {
        
        if sender.row != currentRow { return /*EXIT*/ }
        
        sender.toggle()
        
    }
    
    @IBAction func tapGo(_ sender: UIButton) {
        
        dismissKeyboard()
        
        check()
        
        uiVolatile()
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
        
        textView.layer.borderColor = UIColor(named: "WordleGray")!.cgColor
        textView.layer.borderWidth = Configs.UI.standardBorderWidth
        
        textField.layer.borderColor = UIColor(named: "WordleGray")!.cgColor
        textField.layer.borderWidth = Configs.UI.standardBorderWidth
        textField.delegate = self
        textField.addTarget(self,
                            action: #selector(ViewController.textFieldDidChange(_:)),
                            for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        // Build rowToButton
        for (rowNum, row) in rows.enumerated() {
            
            for view in row.subviews {
                
                let button = view as! UIButton
                
                if rowToButton[rowNum] == nil {
                    rowToButton[rowNum] = [UIButton]()
                }
                
                (button as? WordleButton)?.row = rowNum
                
                rowToButton[rowNum]!.append(button)
                
            }
            
        }
        
    }
    
    private func uiVolatile() {
        
        // Go/Clear
        for rowNum in 0...5 {
            
            let row = rowToButton[rowNum]!
            
            for colNum in 5...6 {
                
                row[colNum].alpha = currentRow == rowNum ? 1 : 0
                
            }
            
        }
        
    }
    
    @objc private func dismissKeyboard() { textField.resignFirstResponder() }
    
    private func resetBoard() {
        
        currentRow = 0
        
        solver.resetMatches()
        
        textField.text = Configs.Defaults.randomStarter()
        textView.text = ""
        
        for rowNum in 0...5 {
            
            let toggleState: ToggleState = rowNum == 0 ? .exclude : .blank
            
            let row = rowToButton[rowNum]!
            for button in row {
                
                if let wb = button as? WordleButton {
                    wb.resetTo(toggleState)
                }
                
            }
            
        }
        
        uiSyncButtonAndTextField()
        uiVolatile()
        
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        uiSyncButtonAndTextField()
        
    }
    
    private func uiSyncButtonAndTextField() {
        
        var letters = Array(textField.text!)
        
        goButton.isEnabled = letters.count == 5
        
        letters.padTo(finalCount: 5, with: "-")
        
        for colNum in 0...4 {
            
            let letter = String(letters[colNum]).uppercased()
            
            let row = rowToButton[currentRow]!
            let button = row[colNum]
            button.setTitle(letter, for: .normal)
            
        }
        
    }
    
    private func check() {
        
        textView.text = ""
        
        guard let guess = textField.text, guess.count == 5
        else {
            
            textView.text = "Guess must be exactly 5 letters."
            return /*EXIT*/
            
        }
        
        let letters = Array(textField.text!)
        
        var exacts      = ["-", "-", "-", "-", "-"]
        var inclusions  = ["-", "-", "-", "-", "-"]
        var exclusions  = ["-", "-", "-", "-", "-"]
        
        for colNum in 0...4 {
            
            let row = rowToButton[currentRow]!
            let button = row[colNum] as! WordleButton
            
            let letter = String(letters[colNum]).uppercased()
                        
            if button.isWrong {         exclusions[colNum] = letter }
            else if button.isClose {    inclusions[colNum] = letter  }
            else if button.isExact {    exacts[colNum] = letter  }
            
        }
        
        let possibleSolutions = solver.updateMatches(exclusionsX: exclusions,
                                                     inclusionsX: inclusions,
                                                     exactsX: exacts)
        
        let suggested = possibleSolutions.suggested.uppercased()
        let remaining = possibleSolutions.remaining
        
        // Advance Current Row
        currentRow = currentRow < 5 ? currentRow + 1 : currentRow
        
        textField.text = suggested.uppercased()
        textFieldDidChange(textField)
        
        var possibles = "\(remaining.count) REMAINING CANDIDATES:\n"
        
        Array(remaining)
            .sorted{ $0.value > $1.value }
            .map{ "\($0.key.uppercased()):\($0.value) "}
            .forEach{ possibles += $0 }
        
        textView.text = """
                        
                        --------------------------------------
                                 SUGGESTION: \(suggested)
                        --------------------------------------
                         EXACT:\t[ \(exacts.joined(separator: " ][ ")) ]
                         INEXACT:\t[ \(inclusions.joined(separator: " ][ ")) ]
                         EXCLUDE:\t[ \(exclusions.joined(separator: " ][ ")) ]
                        --------------------------------------
                        
                        \(possibles)
                        
                        """
        
        if remaining.count == 1 { victory() }
        
    }
    
    private func victory() {
        
        goButton.isEnabled = false
        
        textView.text = "V-I-C-T-O-R-Y"
        
        // Set Buttons Green
        let buttons = rowToButton[currentRow]!
        buttons.forEach{($0 as? WordleButton)?.toggle(.exact) }
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
    }
    
}
