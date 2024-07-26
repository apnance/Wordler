//
//  TestViewController.swift
//  Wordler
//
//  Created by Aaron Nance on 5/21/24.
//

import UIKit
import APNUtil
import ConsoleView

class ConsoleViewController: UIViewController {
    
    @IBOutlet weak var consoleView: ConsoleView!
    private let solver = Solver.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start Console Configuration
        WordlerCommandConfigurator(consoleView: consoleView,
                                   solver: solver)
        
    }
    
}
