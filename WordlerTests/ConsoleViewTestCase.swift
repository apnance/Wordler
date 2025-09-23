//
//  ConsoleViewTestCase.swift
//  Wordler
//
//  Created by Aaron Nance on 9/19/25.
//

import XCTest
import UIKit
import APNUtil
@testable import ConsoleView
@testable import FrameworkTestSupport

// courtesy of ChatGPT
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    if Configs.shouldShuntTestPrintMessages { return } // EXIT : Shunted
    
    var output = ""
    
    for (index, item) in items.enumerated() {
        
        if index > 0 { output += separator }
        
        output += String(describing: item)
        
    }
    
    // Call the original print function if needed
    Swift.print(output, separator: separator, terminator: terminator)
    
}

@available(iOS 16, *)
class ConsoleViewTestCase: XCTestCase  {
    
    // NOTE: must import both to replicate ConsoleViewTestCase found in ConsoleView unit tests.
    // @testable import ConsoleView
    // @testable import FrameworkTestSupport
    
    // BEG : Convenience Shortcuts
    var console: Console { utils.console}
    var utils = CommandTestUtils()
    var consoleView: ConsoleView? {
        get { utils.consoleView }
        set { utils.consoleView = newValue }
    }
    
    override func setUp() {
        
        super.setUp()
        
        // Initializing a ConsoleView triggers initializion of Console singleton
        // shared with this ConsoleView set as the singelton's ConsoleView.
        consoleView = ConsoleView(frame: CGRect.zero)
        
        // Load HelperConfigurator Test Commands Into Console
        TestConfigurator()
        
    }

    
}
