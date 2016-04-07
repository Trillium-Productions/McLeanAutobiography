//
//  locationdata.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/3/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import Foundation
import UIKit

enum LocationDataPageNumber: Int {
    case Cover = 0
    case PageOne = 1
    case PageTwo = 2
    case PageThree = 3
    
    func getKey() -> String {
        switch self {
        case .Cover:
            return "cover"
        case .PageOne:
            return "1"
        case .PageTwo:
            return "2"
        case .PageThree:
            return "3"
        }
    }
    
    func getImageWithStyle(style: LocationDataStyle) -> UIImage {
        switch self {
        case .Cover:
            return UIImage(named: "\(style.getKey())-cover")!
        default:
            return UIImage(named: "\(style.getKey())-page\(getKey())")!
        }
    }
}

enum LocationDataStyle {
    case Handwritten
    case Typed
    
    func getKey() -> String {
        switch self {
        case .Handwritten:
            return "handwritten"
        case .Typed:
            return "typed"
        }
    }
    
    func getImageToken() -> String {
        switch self {
        case .Handwritten:
            return "Handwritten"
        case .Typed:
            return "Typed"
        }
    }
    
    func getImageForPage(pageno: LocationDataPageNumber) -> UIImage {
        switch pageno {
        case .Cover:
            return UIImage(named: "\(getKey())-cover")!
        default:
            return UIImage(named: "\(getKey())-page\(pageno.getKey())")!
        }
    }
}

class LocationInstance: NSObject {
    let imageName: String
    let frame: CGRect
    let index: Int
    
    init(imageName: String, frame: CGRect, index: Int) {
        self.imageName = imageName
        self.frame = frame
        self.index = index
        super.init()
    }
    
    func getBlueImage() -> UIImage {
        return UIImage(named: "\(imageName)Blue")!
    }
    
    func getPurpleImage() -> UIImage {
        return UIImage(named: "\(imageName)Purple")!
    }
    
    func getPopupImage() -> UIImage {
        return UIImage(named: "popup-image-\(index)")!
    }
    
    func getFrameInContainerWithSize(containerSize: CGSize) -> CGRect {
        let x = frame.origin.x * containerSize.width
        let y = frame.origin.y * containerSize.height
        let width = frame.width * containerSize.width
        let height = frame.height * containerSize.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

class LocationDataSet: NSObject {
    let index: Int
    let buttons: [LocationInstance]
    
    init(index: Int, buttons: [LocationInstance]) {
        self.index = index
        self.buttons = buttons
        super.init()
    }
}

class LocationDataPage: NSObject {
    let number: LocationDataPageNumber
    let sets: [LocationDataSet]
    
    init(number: LocationDataPageNumber, sets: [LocationDataSet]) {
        self.number = number
        self.sets = sets
        super.init()
    }
}

class LocationDataDocument: NSObject {
    let style: LocationDataStyle
    let pages: [LocationDataPage]
    
    init(style: LocationDataStyle, pages: [LocationDataPage]) {
        self.style = style
        self.pages = pages
        super.init()
    }
    
    func pageForPageNumber(pageno: LocationDataPageNumber) -> LocationDataPage {
        return pages[pageno.rawValue]
    }
}

class LocationDataProvider: NSObject {
    
    static func getBasisDictionary() -> NSDictionary {
        if let url = NSBundle.mainBundle().URLForResource("hot-button-positions", withExtension: "plist") {
            if let dict = NSDictionary(contentsOfURL: url) {
                return dict
            } else {
                fatalError("Unable to get data for hot button locations")
            }
        } else {
            fatalError("Unable to get URL for hot button locations data file")
        }
    }
    
    static func getDataForStyle(style: LocationDataStyle) -> LocationDataDocument {
        let dict = getBasisDictionary().valueForKey(style.getKey()) as! NSDictionary
        var pages: [LocationDataPage] = []
        let numbers: [LocationDataPageNumber] = [ .Cover, .PageOne, .PageTwo, .PageThree ]
        for num in numbers {
            let pageData = dict.valueForKey("pages.\(num.getKey())") as! [NSDictionary]
            var sets: [LocationDataSet] = []
            for datum in pageData {
                let index = datum.valueForKey("index") as! Int
                var rects: [LocationInstance] = []
                var subindex = 1
                for frame in datum.valueForKey("locations") as! [NSDictionary] {
                    let x = frame.valueForKey("frame.x") as! Double
                    let y = frame.valueForKey("frame.y") as! Double
                    let width = frame.valueForKey("frame.width") as! Double
                    let height = frame.valueForKey("frame.height") as! Double
                    let imageName = "\(style.getImageToken())-HotButton\(index)-Line\(subindex)-"
                    rects.append(LocationInstance(imageName: imageName, frame: CGRect(x: x, y: y, width: width, height: height), index: index))
                    subindex++
                }
                sets.append(LocationDataSet(index: index, buttons: rects))
            }
            pages.append(LocationDataPage(number: num, sets: sets))
        }
        return LocationDataDocument(style: style, pages: pages)
    }
    
}