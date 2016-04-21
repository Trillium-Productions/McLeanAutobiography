//
//  infoview.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/2/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

protocol InfoViewDelegate {
    func infoViewContinueWasTapped()
}

@IBDesignable class InfoView: UIView {
    
    var contAnimation: CABasicAnimation!
    @IBOutlet weak var continueImage: UIImageView!
    var delegate: InfoViewDelegate?
    
    private func create() {
        let arr = NSBundle.mainBundle().loadNibNamed("infoview", owner: self, options: nil)
        for thing in arr {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
        let rec = UITapGestureRecognizer(target: self, action: "onContinueTap")
        rec.numberOfTapsRequired = 1
        rec.numberOfTouchesRequired = 1
        continueImage.addGestureRecognizer(rec)
        let mImage = UIImage(named: "conintue-mask")!
        let mSize = CGSize(width: mImage.size.width * 80 / mImage.size.height, height: 80)
        let contMask = CALayer()
        contMask.contents = mImage.CGImage
        contMask.frame = CGRect(origin: CGPoint.zero, size: mSize)
        contAnimation = CABasicAnimation(keyPath: "position.x")
        contAnimation.fromValue = 4 * continueImage.frame.width / 3
        contAnimation.toValue = -continueImage.frame.width / 3
        contAnimation.repeatCount = HUGE
        contAnimation.duration = 2.5
        contAnimation.removedOnCompletion = false
        continueImage.layer.mask = contMask
        startAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
    func startAnimating() {
        continueImage.layer.mask?.addAnimation(contAnimation, forKey: "position.x")
    }
    
    func stopAnimating() {
        continueImage.layer.mask?.removeAllAnimations()
    }
    
    func onContinueTap() {
        delegate?.infoViewContinueWasTapped()
    }
    
}