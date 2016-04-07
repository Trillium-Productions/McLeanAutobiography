//
//  maininteractive.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/2/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

class MainViewController : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var scroller: UIScrollView!
    @IBOutlet var content: BackgroundView!
    var pager: PagesViewController!
    
    override func viewDidLoad() {
        scroller = view as! UIScrollView
        content = BackgroundView(parent: self)
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
            scroller.scrollEnabled = false
            pager.utilityOverlay.showToolbar(withCompletion: nil, alsoShowHelp: true)
        }
    }
    
    func handleBackRequest() {
        view.userInteractionEnabled = false
        pager.utilityOverlay.hideToolbar { () -> Void in
            self.scroller.scrollEnabled = true
            self.scroller.setContentOffset(CGPoint.zero, animated: true)
            self.view.userInteractionEnabled = true
        }
    }
}
