//
//  HotButtonLocations.m
//  autobiography
//
//  Created by William Rosenbloom on 4/21/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

#import "locations.h"

@implementation DataProvider

+ (NSDictionary *)getHotButtonsLocationsDictionary {
    static NSDictionary *hbdict;
    static dispatch_once_t hbOnceToken;
    dispatch_once(&hbOnceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"hot-button-positions" ofType:@"plist"];
        hbdict = [NSDictionary dictionaryWithContentsOfFile:path];
    });
    return hbdict;
}

+ (NSArray *)getPopupsSizesDictionary {
    static NSArray *pudict;
    static dispatch_once_t puOnceToken;
    dispatch_once(&puOnceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"popup-sizes" ofType:@"plist"];
        pudict = [NSArray arrayWithContentsOfFile:path];
    });
    return pudict;
}

@end