//
//  toolbarview.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/3/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

class PassingView: UIView {
    
    private(set) var isNotClear = false
    
    func becomeVisible(duration: NSTimeInterval, completion: (() -> Void)?) {
        if isNotClear {
            completion?()
        } else {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.alpha = 1
            }, completion:
                { (finished: Bool) -> Void in
                    self.isNotClear = true
                    completion?()
                }
            )
        }
    }
    
    func becomeInvisible(duration: NSTimeInterval, completion: (() -> Void)?) {
        if isNotClear {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.alpha = 0
                }, completion:
                { (finished: Bool) -> Void in
                    self.isNotClear = false
                    completion?()
                }
            )
        } else {
            completion?()
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if isNotClear {
            return super.pointInside(point, withEvent: event)
        } else {
            return false
        }
    }
    
}

protocol ToolbarViewDelegate {
    func toolbarReceivedPageRightCommand(toolbar: ToolbarView)
    func toolbarReceivedPageLeftCommand(toolbar: ToolbarView)
    func toolbar(toolbar: ToolbarView, receivedCommandToChangeStyleTo nextStyle: LocationDataStyle)
    func toolbarReceivedBackRequest(toolbar: ToolbarView)
}

enum ToolbarPresentationState {
    case Visible
    case Invisible
    case Animating
}

@IBDesignable class ToolbarView: UIView, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topbar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var helpScreen: PassingView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftPager: UIButton!
    @IBOutlet weak var rightPager: UIButton!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var gotItButton: UIButton!
    
    private(set) var helpPresentationState = ToolbarPresentationState.Invisible
    private(set) var barPresentationState = ToolbarPresentationState.Invisible
    
    var delegate: ToolbarViewDelegate?
    
    func create() {
        let arr = NSBundle.mainBundle().loadNibNamed("toolbarview", owner: self, options: nil)
        for thing in arr {
            if let view = thing as? UIView {
                addSubview(view)
            }
        }
        segments.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Corbel", size: 26)!], forState: .Normal)
        makeGotItNormal()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if helpPresentationState == .Visible && helpScreen.frame.contains(point) {
            return true
        } else if topbar.frame.contains(point) {
            return true
        } else if bottomBar.frame.contains(point) {
            return true
        } else if leftPager.frame.contains(point) {
            return true
        } else if rightPager.frame.contains(point) {
            return true
        } else {
            return false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
    func showUp(completion: (() -> Void)?) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.topConstraint.constant = 0
            self.layoutIfNeeded()
            }) { (finished: Bool) -> Void in
                completion?()
        }
    }
    
    func goAway(completion: (() -> Void)?) {
        hideToolbar { () -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.topConstraint.constant = -90
                self.layoutIfNeeded()
                }, completion: { (finished: Bool) -> Void in
                    completion?()
            })
        }
    }
    
    func showHelpScreen(withCompletion completion: (() -> Void)?) {
        if barPresentationState == .Visible && helpPresentationState == .Invisible {
            helpPresentationState == .Animating
            helpScreen.becomeVisible(0.5, completion: { () -> Void in
                self.helpPresentationState = .Visible
                completion?()
            })
        } else {
            completion?()
        }
    }
    
    func hideHelpScreen(withCompletion completion: (() -> Void)?) {
        if helpPresentationState == .Visible {
            helpPresentationState = .Animating
            helpScreen.becomeInvisible(0.5, completion: { () -> Void in
                self.helpPresentationState = .Invisible
                completion?()
            })
        } else {
            completion?()
        }
    }
    
    func toggleHelpScreenVisible(withCompletion completion: (() -> Void)?) {
        switch helpPresentationState {
        case .Visible:
            hideHelpScreen(withCompletion: completion)
            break
        case .Invisible:
            showHelpScreen(withCompletion: completion)
            break
        case .Animating:
            completion?()
            break
        }
    }
    
    func showToolbar(withCompletion completion: (() -> Void)?, alsoShowHelp shafter: Bool) {
        if barPresentationState == .Invisible {
            barPresentationState = .Animating
            UIView.animateWithDuration(0.5, delay: 0, options: .LayoutSubviews, animations:
                { () -> Void in
                    self.leftPager.alpha = 1
                    self.rightPager.alpha = 1
                    self.bottomConstraint.constant = 0
                    self.layoutIfNeeded()
                }, completion: { (finished: Bool) -> Void in
                    self.barPresentationState = .Visible
                    if shafter {
                        self.showHelpScreen(withCompletion: completion)
                    } else {
                        completion?()
                    }
            })
        } else {
            completion?()
        }
    }
    
    func hideToolbar(withCompletion completion: (() -> Void)?) {
        if barPresentationState == .Visible {
            if helpPresentationState == .Visible {
                self.hideHelpScreen(withCompletion: { () -> Void in
                    self.hideToolbar(withCompletion: completion)
                })
            } else {
                barPresentationState = .Animating
                UIView.animateWithDuration(0.5, delay: 0, options: .LayoutSubviews, animations:
                    { () -> Void in
                        self.leftPager.alpha = 0
                        self.rightPager.alpha = 0
                        self.bottomConstraint.constant = -90
                        self.layoutIfNeeded()
                    }, completion: { (finished: Bool) -> Void in
                        self.barPresentationState = .Invisible
                        completion?()
                })
            }
        } else {
            completion?()
        }
    }
    
    func toggleToolbar(withCompletion completion: (() -> Void)?, alsoToggleHelp thafter: Bool) {
        switch barPresentationState {
        case .Visible:
            hideToolbar(withCompletion: completion)
            break
        case .Invisible:
            showToolbar(withCompletion: completion, alsoShowHelp: thafter)
            break
        case .Animating:
            completion?()
            break
        }
    }
    
    func setupForPage(pageno: LocationDataPageNumber) {
        switch pageno {
        case .Cover:
            topLabel.text = "Cover Letter"
            pageIndicator.currentPage = 0
            break
        case .PageOne:
            topLabel.text = "Page 1 of 3"
            pageIndicator.currentPage = 1
            break
        case .PageTwo:
            topLabel.text = "Page 2 of 3"
            pageIndicator.currentPage = 2
            break
        case .PageThree:
            topLabel.text = "Page 3 of 3"
            pageIndicator.currentPage = 3
            break
        }
    }
    
    @IBAction func onRightPagerClick() {
        delegate?.toolbarReceivedPageRightCommand(self)
    }
    
    @IBAction func onLeftPagerClick() {
        delegate?.toolbarReceivedPageLeftCommand(self)
    }
    
    @IBAction func onHelpScreenTap(sender: AnyObject) {
        userInteractionEnabled = false
        hideHelpScreen { () -> Void in
            self.userInteractionEnabled = true
        }
    }
    
    @IBAction func onToggleStyle() {
        let target = segments.selectedSegmentIndex == 0 ? LocationDataStyle.Handwritten : LocationDataStyle.Typed
        delegate?.toolbar(self, receivedCommandToChangeStyleTo: target)
    }
    
    @IBAction func onBackClick() {
        delegate?.toolbarReceivedBackRequest(self)
    }
    
    @IBAction func onHelpClick() {
        userInteractionEnabled = false
        toggleHelpScreenVisible { () -> Void in
            self.userInteractionEnabled = true
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let current = pageViewController.viewControllers![0] as! SinglePageViewController
            setupForPage(current.pageno)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let sframe = convertRect(segments.frame, fromView: topbar)
        let location = touch.locationInView(self)
        if sframe.contains(location) {
            return false
        }
        return true
    }
    
    func makeGotItNormal() {
        gotItButton.layer.borderColor = UIColor.whiteColor().CGColor
        gotItButton.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func onGotItDown() {
        gotItButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        gotItButton.backgroundColor = UIColor.lightTextColor()
    }
    
    @IBAction func onGatItCancel() {
        makeGotItNormal()
    }
    
    @IBAction func onGotItTouchUp() {
        makeGotItNormal()
    }
    
    @IBAction func onGotItClick() {
        makeGotItNormal()
        hideHelpScreen(withCompletion: nil)
    }
}
