//
//  TestViewController.swift
//  Wordler
//
//  Created by Aaron Nance on 5/21/24.
//

import UIKit
import APNUtil
import APNConsoleView

class ConsoleViewController: UIViewController {
    
    @IBOutlet weak var consoleView: APNConsoleView!
    private let solver = Solver.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//         HERE...
//        // TODO: Clean Up - finalize UI for summoning/managing the console view.
        
        uiInitConsole()
        
    }
    
    
    func uiInitConsole() {
        
        consoleView.layer.borderColor = Configs.UI.Color.wordleGrayDark?.cgColor
        consoleView.layer.borderWidth = Configs.UI.standardBorderWidth
        
        WordlerCommandConfigurator(consoleView: consoleView,
                                   solver: solver)
        
    }
    
}
