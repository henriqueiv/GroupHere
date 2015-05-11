//
//  RoundedImageView.swift
//  GroupHere
//
//  Created by Henrique Valcanaia on 5/8/15.
//  Copyright (c) 2015 Henrique Valcanaia. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    
    override func layoutSubviews() {
        self.roundCorner()
    }
    
    func roundCorner(){
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.cornerRadius = self.layer.visibleRect.size.height/2
        self.layer.borderWidth = 1.0;
        self.layer.masksToBounds = true;
    }
    
}
