//
//  TravelActivation.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 18..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelActivation.h"

@implementation TravelActivation

+ (instancetype)defaultInstance {
    static TravelActivation *objcet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objcet = [[self alloc] init];
    });
    return objcet;
}

@end
