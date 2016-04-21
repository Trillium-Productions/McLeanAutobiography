//
//  backgroundview.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/2/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

@IBDesignable class BackgroundView : UIView {
    
    @IBOutlet var infoView: InfoView!
    var parent: MainViewController?
    
    func create() {
        let arr = NSBundle.mainBundle().loadNibNamed("scrollbackground", owner: self, options: nil)
        for thing in arr {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
    }
    
    override init(frame: CGRect) {
        parent = nil
        super.init(frame: frame)
        create()
    }

    required init?(coder aDecoder: NSCoder) {
        parent = nil
        super.init(coder: aDecoder)
        create()
    }
    
    init(parent: MainViewController) {
        self.parent = parent
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 2048, height: 768)))
        create()
    }
    
}