//
//  popups.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/21/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

enum PopupIndex: Int {
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
    case Five = 5
    case Six = 6
    case Seven = 7
    case Eight = 8
    case Nine = 9
    case Ten = 10
    case Eleven = 11
    case Twelve = 12
    case Thirteen = 13
    case Fourteen = 14
    case Fifteen = 15
    case Sixteen = 16
    case Seventeen = 17
    case Eighteen = 18
    case Nineteen = 19
    case Twenty = 20
    
    func getPopupImage() -> UIImage {
        return UIImage(named: "popup-image-\(rawValue)")!
    }
    
    func getFrame() -> CGRect {
        let source = DataProvider.getPopupsSizesDictionary()
        let dict = source[rawValue - 1]
        let width = dict["width"]!.doubleValue
        let height = dict["height"]!.doubleValue
        let left = dict["left"]!.doubleValue
        let top = dict["top"]!.doubleValue
        return CGRect(x: left, y: top, width: width, height: height)
    }
}

class PopupImageView: UIView {
    let scroller: UIScrollView
    let image: UIImageView
    let index: PopupIndex
    let exitButton: UIButton
    
    private(set) var hasPoppedUp = false
    
    private static func createCustomScroller(inFrame rect: CGRect) -> UIScrollView {
        let scroller = UIScrollView(frame: rect)
        scroller.bounces = true
        scroller.bouncesZoom = true
        scroller.maximumZoomScale = 2
        scroller.minimumZoomScale = 1
        scroller.pagingEnabled = false
        scroller.contentSize = scroller.bounds.size
        scroller.canCancelContentTouches = true
        scroller.backgroundColor = UIColor.clearColor()
        scroller.showsHorizontalScrollIndicator = false
        scroller.showsVerticalScrollIndicator = false
        return scroller
    }
    
    private static func createExitFrame(inFrame rect: CGRect) -> CGRect {
        let size = CGSize(width: 40, height: 40)
        let origin = CGPoint(x: rect.width - size.width - 9, y: rect.height - size.height + 9)
        return CGRect(origin: origin, size: size)
    }
    
    init(withIndex _index: PopupIndex, inFrame rect: CGRect) {
        index = _index
        scroller = PopupImageView.createCustomScroller(inFrame: rect)
        image = UIImageView(frame: scroller.bounds)
        image.image = index.getPopupImage()
        scroller.addSubview(image)
        let eOrigin = CGPoint(x: scroller.bounds.width, y: scroller.bounds.height)
        exitButton = UIButton(frame: CGRect(origin: eOrigin, size: CGSizeZero))
        exitButton.setImage(UIImage(named: "exit-black"), forState: .Normal)
        exitButton.setImage(UIImage(named: "exit-gray"), forState: .Highlighted)
        super.init(frame: rect)
        userInteractionEnabled = false
        addSubview(scroller)
        addSubview(exitButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func popupToFullSize(completion: (() -> Void)?) {
        if hasPoppedUp {
            completion?()
        } else {
            hasPoppedUp = true
            let fullFrame = index.getFrame()
            let fullBounds = CGRect(origin: CGPoint.zero, size: fullFrame.size)
            let eFrame = PopupImageView.createExitFrame(inFrame: fullFrame)
            UIView.animateWithDuration(0.5, delay: 0.1, options: .CurveEaseInOut, animations:
                { () -> Void in
                    self.frame = fullFrame
                    self.scroller.frame = fullFrame
                    self.image.frame = fullBounds
                    self.exitButton.frame = eFrame
                }, completion: { (finished: Bool) -> Void in
                    self.scroller.setContentOffset(CGPoint.zero, animated: false)
                    self.scroller.contentSize = self.scroller.bounds.size
                    self.userInteractionEnabled = true
                    completion?()
            })
        }
    }
}

class PopupView: UIVisualEffectView {
    let popup: PopupImageView
    
    init(index: PopupIndex, initialFrame rect: CGRect) {
        popup = PopupImageView(withIndex: index, inFrame: rect)
        super.init(effect: UIBlurEffect(style: .Dark))
        popup.exitButton.addTarget(self, action: "removeFromSuperview", forControlEvents: .TouchUpInside)
        frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 768))
        contentView.addSubview(popup)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doPopup(withCompletion completion: (() -> Void)?) {
        popup.popupToFullSize(completion)
    }
}