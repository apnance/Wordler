//
//  ProgressIndicator.swift
//  Wordler
//
//  Created by Aaron Nance on 8/3/23.
//

import UIKit

class ProgressIndicator: UIView {
    
    private var rowViews = [IndicatorRowView]()
    private var totalWords = 0
    
    static func make(targetView: UIView, totalWordCount: Int) -> ProgressIndicator? {
        
        if let progIndView = UINib.instanceFromNib("ProgressIndicator") as? ProgressIndicator {
            
            progIndView.frame   = targetView.bounds
            targetView.addSubview(progIndView)
            
            progIndView.totalWords = totalWordCount
            
            return progIndView /*EXIT*/
            
        }
        
        return nil /*EXIT*/
        
    }
    
    var words = [(String, Int)]()
  
    public func reset() {
        
        words.removeAll()
        ui()
        
    }
    
    private func ui() {
        
        var words = words
        words.padTo(finalCount: rowViews.count, with: ("", 0))
        
        for (i, view) in rowViews.enumerated() {
            
            let (word, count) = words[i]
            let label = word.isEmpty ? "" : "\(word)"
            
            (view.subviews.last as? UILabel)?.text = label
            
            view.setBar(num: count, of: totalWords)
            
        }
    }
    
    public func update(word: String, remaining: Int) {
        
        words.append((word,remaining))
        
        ui()
        
    }
    
    override func awakeFromNib() {
        
        for view in subviews.first!.subviews {
            
            if let view = view as? IndicatorRowView {
             
                rowViews.append(view)
                
            }
        }
        
    }
    
    
}

class IndicatorRowView: UIView {
    
    var bar: UIView!
    
    override func awakeFromNib() {
        
        layer.borderWidth   = 2
        layer.borderColor   = UIColor(named: "WordleGrayDark")?.cgColor
        
        (subviews.first as? UILabel)?.text = ""
        
        bar = UIView(frame: CGRect.zero)
        bar.backgroundColor = UIColor(named: "WordleGreen")
        
        addSubview(bar!)
        sendSubviewToBack(bar!)
        
    }
    
    func setBar(num: Int, of total: Int) {
        
        let width = frame.width * (num.double / total.double)
        
        bar?.frame = CGRect(width: width, height: frame.height)
        
    }
    
}
