//
//  pagecreating.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/3/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit

protocol PagesCollectionDelegate {
    func pagesCollectionReceivedHotButtonTap(button: HotButtonView, inSet set: HotButtonSet, inPage: SinglePageViewController)
}

class PagesCollection: NSObject, UIPageViewControllerDataSource {
    
    let cover: SinglePageViewController
    let one: SinglePageViewController
    let two: SinglePageViewController
    let three: SinglePageViewController
    private(set) var style: LocationDataStyle
    var delegate: PagesCollectionDelegate?
    
    init(withStyle chosenStyle: LocationDataStyle) {
        let data = LocationDataProvider.getDataForStyle(chosenStyle)
        cover = SinglePageViewController(style: chosenStyle, pageNumber: .Cover, withData: data.pages[0])
        one = SinglePageViewController(style: chosenStyle, pageNumber: .PageOne, withData: data.pages[1])
        two = SinglePageViewController(style: chosenStyle, pageNumber: .PageTwo, withData: data.pages[2])
        three = SinglePageViewController(style: chosenStyle, pageNumber: .PageThree, withData: data.pages[3])
        style = chosenStyle
        super.init()
        cover.actionOnTap = onButtonTap
        one.actionOnTap = onButtonTap
        two.actionOnTap = onButtonTap
        three.actionOnTap = onButtonTap
    }
    
    func onButtonTap(set: HotButtonSet, button: HotButtonView, page: SinglePageViewController) {
        delegate?.pagesCollectionReceivedHotButtonTap(button, inSet: set, inPage: page)
    }
    
    func getPageWithPageNumber(pageno: LocationDataPageNumber) -> SinglePageViewController {
        switch pageno {
        case .Cover:
            return cover
        case .PageOne:
            return one
        case .PageTwo:
            return two
        case .PageThree:
            return three
        }
    }
    
    private func getPagesNotMatchingPageNumber(pageno: LocationDataPageNumber) -> [SinglePageViewController] {
        switch pageno {
        case .Cover:
            return [ one, two, three ]
        case .PageOne:
            return [ cover, two, three ]
        case .PageTwo:
            return [ cover, one, three ]
        case .PageThree:
            return [ cover, one, two ]
        }
    }
    
    func transitionToStyle(newStyle: LocationDataStyle, animatedPage: LocationDataPageNumber, withCompletion completion: (() -> Void)?) {
        let data = LocationDataProvider.getDataForStyle(newStyle)
        for view in getPagesNotMatchingPageNumber(animatedPage) {
            view.resetForStyle(newStyle, withData: data.pages[view.pageno.rawValue], animated: false, completion: nil)
        }
        getPageWithPageNumber(animatedPage).resetForStyle(newStyle, withData: data.pages[animatedPage.rawValue], animated: true, completion: completion)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let pvc = viewController as! SinglePageViewController
        switch pvc.pageno! {
        case .Cover:
            return one
        case .PageOne:
            return two
        case .PageTwo:
            return three
        case .PageThree:
            return cover
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pvc = viewController as! SinglePageViewController
        switch pvc.pageno! {
        case .Cover:
            return three
        case .PageOne:
            return cover
        case .PageTwo:
            return one
        case .PageThree:
            return two
        }
    }
}