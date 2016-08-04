//
//  rootViewControllerObject.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 28..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "rootViewControllerObject.h"

@implementation rootViewControllerObject

+ (instancetype)defaultInstance {
    static rootViewControllerObject *object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[self alloc] init];
    });
    return object;
}



@end
