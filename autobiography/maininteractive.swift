//
//  maininteractive.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/2/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

class MainViewController : UIViewController, UIScrollViewDelegate, InfoViewDelegate {
    
    @IBOutlet var scroller: UIScrollView!
    @IBOutlet var content: BackgroundView!
    var pager: PagesViewController!
    private(set) var hasScrolledToAutobio = false
    
    override func viewDidLoad() {
        scroller = view as! UIScrollView
        content.parent = self
        content.infoView.delegate = self
        scroller.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scroller.contentSize = content.frame.size
        scroller.contentMode = .Left
        scroller.pagingEnabled = true
        scroller.bounces = false
        scroller.showsHorizontalScrollIndicator = false
        scroller.showsVerticalScrollIndicator = false
        scroller.delegate = self
        pager = PagesViewController(initialStyle: .Handwritten)
        addChildViewController(pager)
        pager.view.frame = CGRect(origin: CGPoint(x: 1024, y: 0), size: CGSize(width: 1024, height: 768))
        view.addSubview(pager.view)
        pager.didMoveToParentViewController(self)
        super.viewDidLoad()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scroller.contentOffset.x == 1024 {
            view.userInteractionEnabled = false
            scroller.scrollEnabled = false
            pager.utilityOverlay.showUp({ () -> Void in
                self.pager.utilityOverlay.showToolbar(withCompletion:
                    { () -> Void in
                        self.view.userInteractionEnabled = true
                    }
                    , alsoShowHelp: !self.hasScrolledToAutobio)
                self.hasScrolledToAutobio = true
            })
        }
    }
    
    func handleBackRequest() {
        view.userInteractionEnabled = false
        pager.utilityOverlay.hideToolbar { () -> Void in
            self.pager.utilityOverlay.goAway({ () -> Void in
                self.scroller.scrollEnabled = true
                self.scroller.setContentOffset(CGPoint.zero, animated: true)
                self.view.userInteractionEnabled = true
            })
        }
    }
    
    func infoViewContinueWasTapped() {
        view.userInteractionEnabled = false
        scroller.setContentOffset(CGPoint(x: 1024, y: 0), animated: true)
        pager.utilityOverlay.showUp { () -> Void in
            self.pager.utilityOverlay.showToolbar(withCompletion: { () -> Void in
                self.view.userInteractionEnabled = true
                }, alsoShowHelp: !self.hasScrolledToAutobio)
            self.hasScrolledToAutobio = true
        }
    }
}
