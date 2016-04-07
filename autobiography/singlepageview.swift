//
//  pagesview.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/3/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

protocol HotButtonDelegate {
    func hotButtonReceivedClick(hotButton: HotButtonView)
}

class HotButtonView: UIButton, UIGestureRecognizerDelegate {
    let basis: LocationInstance
    var delegate: HotButtonDelegate?
    private(set) var hasBeenClicked: Bool
    
    init(basis: LocationInstance, inFrameSize rect: CGSize, hasBeenClicked: Bool) {
        self.basis = basis
        self.hasBeenClicked = hasBeenClicked
        super.init(frame: basis.getFrameInContainerWithSize(rect))
        if hasBeenClicked {
            setImage(basis.getPurpleImage(), forState: .Normal)
        } else {
            setImage(basis.getBlueImage(), forState: .Normal)
        }
        // addTarget(self, action: "onClick", forControlEvents: .PrimaryActionTriggered)
        let rec = UITapGestureRecognizer(target: self, action: "onClick")
        rec.numberOfTapsRequired = 1
        rec.numberOfTouchesRequired = 1
        rec.cancelsTouchesInView = false
        rec.delegate = self
        addGestureRecognizer(rec)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented by HotButtonView")
    }
    
    func updateForClick() {
        if !hasBeenClicked {
            hasBeenClicked = true
            setImage(basis.getPurpleImage(), forState: .Normal)
        }
    }
    
    func onClick() {
        highlighted = true
        delegate?.hotButtonReceivedClick(self)
        highlighted = false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

protocol HotButtonSetDelegate {
    func hotButtonSetReceivedClick(set: HotButtonSet, fromButton button: HotButtonView)
}

class HotButtonSet: NSObject, HotButtonDelegate {
    let buttons: [HotButtonView]
    let basis: LocationDataSet
    let refSize: CGSize
    private(set) var hasBeenClicked: Bool
    var delegate: HotButtonSetDelegate?
    
    init(basis: LocationDataSet, containerSize: CGSize, hasBeenClicked hist: Bool) {
        self.basis = basis
        refSize = containerSize
        hasBeenClicked = hist
        var _buttons: [HotButtonView] = []
        for instance in basis.buttons {
            _buttons.append(HotButtonView(basis: instance, inFrameSize: containerSize, hasBeenClicked: hasBeenClicked))
        }
        buttons = _buttons
        super.init()
        for spec in buttons {
            spec.delegate = self
        }
    }
    
    func getNewSetForStyle(style: LocationDataStyle, withData data: LocationDataSet, containerSize: CGSize) -> HotButtonSet {
        let next = HotButtonSet(basis: data, containerSize: containerSize, hasBeenClicked: hasBeenClicked)
        next.delegate = delegate
        return next
    }
    
    func addToView(view: UIView) {
        for spec in buttons {
            view.addSubview(spec)
        }
    }
    
    func removeFromSuperview() {
        for spec in buttons {
            spec.removeFromSuperview()
        }
    }
    
    func hotButtonReceivedClick(hotButton: HotButtonView) {
        if !hasBeenClicked {
            hasBeenClicked = true
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                for button in self.buttons {
                    button.updateForClick()
                }
            }
        }
        delegate?.hotButtonSetReceivedClick(self, fromButton: hotButton)
    }
}

protocol SinglePageViewDelegate {
    func singlePageViewReceivedSignalFromSet(set: HotButtonSet, fromButton button: HotButtonView, pageView: SinglePageView)
    func singlePageViewChangedIntrinsicHeight(pageView: SinglePageView, toHeight updated: CGFloat)
    func singlePageViewReceivedGenericTap()
}

class SinglePageView: UIView, HotButtonSetDelegate, UIGestureRecognizerDelegate {
    
    let FULL_WIDTH: CGFloat = 1024
    let INSETS: CGFloat = 90
    
    // must know origin, pageno, style, and locations data
    let pageno: LocationDataPageNumber
    let imageView: UIImageView
    private(set) var style: LocationDataStyle
    private(set) var buttons: [HotButtonSet]
    var delegate: SinglePageViewDelegate?
    
    init(origin: CGPoint, pageNumber: LocationDataPageNumber, style: LocationDataStyle, locsData: LocationDataPage) {
        let pageOrigin = CGPoint(x: INSETS, y: INSETS)
        let pageWidth = FULL_WIDTH - (2 * INSETS)
        self.pageno = pageNumber
        self.style = style
        let _image = pageNumber.getImageWithStyle(style)
        let pageHeight = _image.size.height * pageWidth / _image.size.width
        let height = 2 * INSETS + pageHeight
        imageView = UIImageView(frame: CGRect(origin: pageOrigin, size: CGSize(width: pageWidth, height: pageHeight)))
        imageView.image = _image
        imageView.userInteractionEnabled = true
        let _frame = CGRect(origin: origin, size: CGSize(width: FULL_WIDTH, height: height))
        buttons = []
        for set in locsData.sets {
            buttons.append(HotButtonSet(basis: set, containerSize: imageView.bounds.size, hasBeenClicked: false))
        }
        super.init(frame: _frame)
        for set in buttons {
            set.addToView(imageView)
            set.delegate = self
        }
        addSubview(imageView)
        let rec = UITapGestureRecognizer(target: self, action: "onTapReceived")
        rec.numberOfTapsRequired = 1
        rec.numberOfTouchesRequired = 1
        rec.cancelsTouchesInView = false
        rec.delegate = self
        imageView.addGestureRecognizer(rec)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented for SinglePageView")
    }
    
    func resetForStyle(newStyle: LocationDataStyle, withData data: LocationDataPage) {
        let _image = pageno.getImageWithStyle(newStyle)
        let pageHeight = _image.size.height * imageView.bounds.width / _image.size.width
        let height = pageHeight + 2 * INSETS
        frame = CGRect(origin: frame.origin, size: CGSize(width: FULL_WIDTH, height: height))
        imageView.image = _image
        imageView.frame = CGRect(origin: imageView.frame.origin, size: CGSize(width: imageView.frame.width, height: pageHeight))
        var _buttons: [HotButtonSet] = []
        for (var i = 0; i < buttons.count; i++) {
            _buttons.append(buttons[i].getNewSetForStyle(newStyle, withData: data.sets[i], containerSize: imageView.bounds.size))
            buttons[i].removeFromSuperview()
            _buttons[i].addToView(imageView)
        }
        buttons = _buttons
        style = newStyle
        delegate?.singlePageViewChangedIntrinsicHeight(self, toHeight: height)
    }
    
    func hotButtonSetReceivedClick(set: HotButtonSet, fromButton button: HotButtonView) {
        delegate?.singlePageViewReceivedSignalFromSet(set, fromButton: button, pageView: self)
    }
    
    func onTapReceived() {
        delegate?.singlePageViewReceivedGenericTap()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let pos = touch.locationInView(gestureRecognizer.view!)
        for thing in buttons {
            for view in thing.buttons {
                if view.frame.contains(pos) {
                    return false
                }
            }
        }
        return true
    }
    
}

class SinglePageViewController: UIViewController, SinglePageViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var scroller: UIScrollView!
    private(set) var style: LocationDataStyle
    let pageno: LocationDataPageNumber!
    let pageView: SinglePageView!
    var actionOnTap: ((HotButtonSet, HotButtonView, SinglePageViewController) -> Void)?
    var parent: PagesViewController!
    
    init(style: LocationDataStyle, pageNumber: LocationDataPageNumber, withData: LocationDataPage) {
        pageView = SinglePageView(origin: CGPoint.zero, pageNumber: pageNumber, style: style, locsData: withData)
        pageno = pageNumber
        self.style = style
        super.init(nibName: "singlepageview", bundle: nil)
        pageView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented for SinglePageViewController")
    }
    
    override func viewDidLoad() {
        scroller.contentSize = pageView.frame.size
        scroller.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scroller.scrollEnabled = true
        scroller.bounces = true
        scroller.bouncesZoom = true
        scroller.minimumZoomScale = 1
        scroller.maximumZoomScale = 3
        scroller.pagingEnabled = false
        scroller.panGestureRecognizer.cancelsTouchesInView = false
        scroller.delegate = self
        scroller.addSubview(pageView)
        super.viewDidLoad()
    }
    
    func resetForStyle(newStyle: LocationDataStyle, withData: LocationDataPage, animated: Bool, completion: (() -> Void)?) {
        if animated {
            UIView.transitionWithView(pageView.imageView, duration: 1.1, options: .CurveLinear, animations: { () -> Void in
                self.resetForStyle(newStyle, withData: withData, animated: false, completion: nil)
                }, completion: { (finished: Bool) -> Void in
                    completion?()
            })
        } else {
            pageView.resetForStyle(newStyle, withData: withData)
            style = newStyle
        }
    }
    
    func singlePageViewChangedIntrinsicHeight(pageView: SinglePageView, toHeight updated: CGFloat) {
        if scroller != nil {
            scroller.contentSize = CGSize(width: scroller.contentSize.width, height: updated)
        }
    }
    
    func singlePageViewReceivedSignalFromSet(set: HotButtonSet, fromButton button: HotButtonView, pageView: SinglePageView) {
        actionOnTap?(set, button, self)
    }
    
    func singlePageViewReceivedGenericTap() {
        parent.onTapReceived()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return pageView
    }
}