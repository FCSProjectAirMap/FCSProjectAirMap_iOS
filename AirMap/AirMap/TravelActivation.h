//
//  TravelActivation.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 18..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface TravelActivation : NSObject

@property (nonatomic, strong) TravelList *travelList;

+ (instancetype)defaultInstance;
- (void)travelListActivation:(TravelList *)travelList;

@end
