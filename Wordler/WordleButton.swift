//
//  WordleButton.swift
//  Wordler
//
//  Created by Aaron Nance on 1/13/22.
//

import UIKit

enum ToggleState { case blank, exclude, include, exact }

class WordleButton: UIButton {
    
    var isExact: Bool { toggleState == .exact}
    var isClose: Bool { toggleState == .include }
    var isWrong: Bool { toggleState == .exclude }
    
    private var toggleState = ToggleState.exclude
    var row = 0
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        uiInit()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        uiInit()
        
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        
        super.setTitle(title, for: state)
        
        if title != "" && toggleState == .blank { toggle() }
        
    }
    
    func toggle(_ to: ToggleState? = nil) {
        
        if let to = to {
            
            toggleState = to
            
        } else {
            
            switch toggleState {
                    
                case .blank: toggleState    = .exclude
                    
                case .exclude: toggleState  = .exact
                    

                case .exact: toggleState    = .include
                    
                case .include: toggleState  = .exclude
                    
            }
            
        }
        
        style()
        
    }
    
    func style() {
        
        switch toggleState {
            
            case .blank:
                backgroundColor     = UIColor(named: "WordleBlack")
                layer.borderColor   = UIColor(named: "WordleGray")?.cgColor
            
            case .exclude:
                backgroundColor     = UIColor(named: "WordleGray")
                layer.borderWidth   = 0
            
            case .include:
                backgroundColor     = UIColor(named: "WordleYellow")
                layer.borderWidth   = 0
            
            case .exact:
                backgroundColor     = UIColor(named: "WordleGreen")
                layer.borderWidth   = 0
            
        }
        
    }
    
    func resetTo(_ toggleState: ToggleState) {
        
        self.toggleState = toggleState
        setTitle("", for: .normal)
        style()
        
    }
    
    private func uiInit() {
        
        layer.borderColor   = UIColor.darkGray.cgColor
        layer.borderWidth   = 1.5
        backgroundColor     = UIColor(named: "WordleBlack")
    
        resetTo(.blank)
        
    }
    
}
