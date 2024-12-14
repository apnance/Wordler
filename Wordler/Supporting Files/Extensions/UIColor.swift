            
            /// Creates altenating shades of the specified color for use in coloring consecutive rows of text.
            static func row(_ n: Int, color: UIColor = wordleGrayLight!) -> UIColor {
                
                (n % 2 == 0) ? color.pointSevenAlpha : color.pointFourAlpha
                
            }
            
