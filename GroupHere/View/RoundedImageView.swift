//
//  RoundedImageView.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/8/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImageView: UIImageView {
    
    @IBInspectable var rounded: Bool = false {
        didSet {
            if rounded{
                self.layer.cornerRadius = self.layer.visibleRect.height/2
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor(){
        didSet {
            self.layer.borderColor = borderColor.CGColor
            if (self.layer.borderWidth == 0){
                self.layer.borderWidth = 1.0;
            }
        }
    }
    
}
