//
//  HotButtonLocations.h
//  autobiography
//
//  Created by William Rosenbloom on 4/21/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataProvider : NSObject

+ (NSDictionary * _Nonnull)getHotButtonsLocationsDictionary;
+ (NSArray<NSDictionary<NSString *, NSNumber *> *> * _Nonnull)getPopupsSizesDictionary;

@end