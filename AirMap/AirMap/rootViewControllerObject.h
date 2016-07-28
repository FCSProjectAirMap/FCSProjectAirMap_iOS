//
//  rootViewControllerObject.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 28..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rootViewControllerObject : NSObject

@property (nonatomic, strong) UIViewController *rootViewController;

+ (instancetype)defaultInstance;

@end
