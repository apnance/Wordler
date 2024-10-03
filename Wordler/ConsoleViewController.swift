//
//  TestViewController.swift
//  Wordler
//
//  Created by Aaron Nance on 5/21/24.
//

import UIKit
import APNUtil
import ConsoleView

// TODO: Clean Up - delete THIS FILE - OBSOLETE...
class ConsoleViewController: UIViewController {
    
    @IBOutlet weak var consoleView: ConsoleView!
    private let solver = Solver.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start Console Configuration
        WordlerConsoleConfigurator(consoleView: consoleView,
                                   solver: solver)
        
    }
    
}
