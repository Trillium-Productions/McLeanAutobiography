//
//  customwindow.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/2/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

class CustomWindow: UIWindow {
    
    let appdel: AppDelegate
    
    init(appdelegate: AppDelegate) {
        appdel = UIApplication.sharedApplication().delegate as! AppDelegate
        super.init(frame: UIScreen.mainScreen().bounds)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        appdel.startIdleTimer()
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        appdel.startIdleTimer()
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        appdel.startIdleTimer()
        super.touchesEnded(touches, withEvent: event)
    }
    
}

@objc(CustomApplication) class CustomApplication: UIApplication {
    override func sendEvent(event: UIEvent) {
        if event.type == .Touches {
            (delegate as! AppDelegate).startIdleTimer()
        }
        super.sendEvent(event)
    }
}
