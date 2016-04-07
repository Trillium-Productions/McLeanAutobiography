//
//  pagesview.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/3/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

class PopupOverlay: UIVisualEffectView {
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PagesViewController: UIPageViewController, ToolbarViewDelegate, PagesCollectionDelegate {
    
    let collection: PagesCollection
    let style: LocationDataStyle
    let utilityOverlay: ToolbarView
    private(set) var container: MainViewController!
    
    init(initialStyle chosenStyle: LocationDataStyle) {
        collection = PagesCollection(withStyle: chosenStyle)
        style = chosenStyle
        utilityOverlay = ToolbarView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 768)))
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        collection.cover.parent = self
        collection.one.parent = self
        collection.two.parent = self
        collection.three.parent = self
        collection.delegate = self
        utilityOverlay.delegate = self
        view.addSubview(utilityOverlay)
        dataSource = collection
        delegate = utilityOverlay
        setViewControllers([collection.one], direction: .Forward, animated: false, completion: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented by PagesViewController")
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        container = parent as! MainViewController
        super.didMoveToParentViewController(parent)
    }
    
    func onTapReceived() {
        view.userInteractionEnabled = false
        utilityOverlay.toggleToolbar(withCompletion: { () -> Void in
            self.view.userInteractionEnabled = true
            }, alsoToggleHelp: false)
    }
    
    func toolbar(toolbar: ToolbarView, receivedCommandToChangeStyleTo nextStyle: LocationDataStyle) {
        collection.transitionToStyle(nextStyle, animatedPage: (viewControllers![0] as! SinglePageViewController).pageno, withCompletion: nil)
    }
    
    func toolbarReceivedBackRequest(toolbar: ToolbarView) {
        container.handleBackRequest()
    }
    
    func toolbarReceivedPageLeftCommand(toolbar: ToolbarView) {
        let next = collection.pageViewController(self, viewControllerBeforeViewController: viewControllers![0]) as! SinglePageViewController
        setViewControllers([next], direction: .Reverse, animated: true, completion: { (finished: Bool) -> Void in
            self.utilityOverlay.setupForPage(next.pageno)
        })
    }
    
    func toolbarReceivedPageRightCommand(toolbar: ToolbarView) {
        let next = collection.pageViewController(self, viewControllerAfterViewController: viewControllers![0]) as! SinglePageViewController
        setViewControllers([next], direction: .Forward, animated: true, completion: { (finished: Bool) -> Void in
            self.utilityOverlay.setupForPage(next.pageno)
        })
    }
    
    func pagesCollectionReceivedHotButtonTap(button: HotButtonView, inSet set: HotButtonSet, inPage: SinglePageViewController) {
        let overlay = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        overlay.frame = view.bounds
        let rec = UITapGestureRecognizer(target: overlay, action: "removeFromSuperview")
        rec.numberOfTapsRequired = 1
        rec.numberOfTouchesRequired = 1
        overlay.contentView.addGestureRecognizer(rec)
        view.addSubview(overlay)
        let popup = UIImageView(frame: view.convertRect(button.frame, fromView: button.superview!))
        popup.image = button.basis.getPopupImage()
        overlay.contentView.addSubview(popup)
        UIView.animateWithDuration(0.5) { () -> Void in
            popup.frame = overlay.bounds
        }
    }
    
}