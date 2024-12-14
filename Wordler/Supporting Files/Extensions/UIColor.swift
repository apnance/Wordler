//
//  UIColor.swift
//  Wordler
//
//  Created by Aaron Nance on 12/14/24.
//


import UIKit

extension UIColor {
    
    // TODO: Clean Up - move to APNUtil
    /// Creates alternating shades of the `self` for use in coloring consecutive rows of text.
    func altRow(_ n: Int, _ otherColor: UIColor? = nil) -> UIColor {
        
        (n % 2 == 0) ? self : (otherColor ?? self.halfAlpha)
        
    }
    
}
