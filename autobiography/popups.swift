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

class PopupImageView: UIScrollView, UIScrollViewDelegate {
    let image: UIImageView
    let index: PopupIndex
    let exitButton: UIButton
    
    private(set) var hasPoppedUp = false
    
    private static func createCustomScroller(inFrame rect: CGRect) -> UIScrollView {
        let container = CGRect(origin: CGPoint.zero, size: rect.size)
        let scroller = UIScrollView(frame: container)
        scroller.bounces = true
        scroller.bouncesZoom = true
        scroller.maximumZoomScale = 2
        scroller.minimumZoomScale = 1
        scroller.pagingEnabled = false
        scroller.scrollEnabled = true
        scroller.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scroller.contentSize = rect.size
        scroller.backgroundColor = UIColor.clearColor()
        scroller.showsHorizontalScrollIndicator = false
        scroller.showsVerticalScrollIndicator = false
        return scroller
    }
    
    private static func createExitFrame(inFrame rect: CGRect) -> CGRect {
        let size = CGSize(width: 40, height: 40)
        let origin = CGPoint(x: rect.width - size.width - 15, y: 15)
        return CGRect(origin: origin, size: size)
    }
    
    private static func createTransformToConvertFrame(rect: CGRect, toFrame target: CGRect) -> CGAffineTransform {
        var form = CGAffineTransformIdentity
        let xdelta = target.origin.x - rect.origin.x + 0.5 * (target.width - rect.width)
        let ydelta = target.origin.y - rect.origin.y + 0.5 * (target.height - rect.height)
        form = CGAffineTransformTranslate(form, xdelta, ydelta)
        let xscale = target.width / rect.width
        let yscale = target.height / rect.height
        form = CGAffineTransformScale(form, xscale, yscale)
        return form
    }
    
    init(withIndex _index: PopupIndex, inFrame rect: CGRect) {
        index = _index
        let _frame = index.getFrame()
        image = UIImageView(frame: _frame)
        image.image = index.getPopupImage()
        image.userInteractionEnabled = true
        exitButton = UIButton(frame: PopupImageView.createExitFrame(inFrame: _frame))
        exitButton.setImage(UIImage(named: "exit-black"), forState: .Normal)
        exitButton.setImage(UIImage(named: "exit-gray"), forState: .Highlighted)
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 768)))
        userInteractionEnabled = false
        image.addSubview(exitButton)
        let holder = UIView(frame: bounds)
        holder.backgroundColor = UIColor.clearColor()
        holder.addSubview(image)
        addSubview(holder)
        transform = PopupImageView.createTransformToConvertFrame(_frame, toFrame: rect)
        scrollEnabled = true
        bounces = true
        bouncesZoom = true
        maximumZoomScale = 2
        minimumZoomScale = 1
        backgroundColor = UIColor.clearColor()
        pagingEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        scrollsToTop = false
        let rec = UITapGestureRecognizer(target: self, action: "undoScrollingAndZooming")
        rec.numberOfTapsRequired = 2
        rec.numberOfTouchesRequired = 1
        rec.cancelsTouchesInView = false
        addGestureRecognizer(rec)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func popupToFullSize(completion: (() -> Void)?) {
        if hasPoppedUp {
            completion?()
        } else {
            hasPoppedUp = true
            UIView.animateWithDuration(0.5, delay: 0.1, options: .CurveEaseInOut, animations:
                { () -> Void in
                    self.transform = CGAffineTransformIdentity
                }, completion: { (finished: Bool) -> Void in
                    self.userInteractionEnabled = true
                    completion?()
            })
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let converted = image.convertPoint(point, fromView: self)
        return image.pointInside(converted, withEvent: event)
    }
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        return true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return image.superview
    }
    
    func undoScrollingAndZooming() {
        userInteractionEnabled = false
        setZoomScale(1, animated: true)
        setContentOffset(CGPoint.zero, animated: true)
        userInteractionEnabled = true
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