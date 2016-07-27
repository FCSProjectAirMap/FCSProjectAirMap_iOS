//
//  TravelList.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 14..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelList.h"

@implementation TravelList

// primary key 생성.
+ (NSString *)primaryKey {
    return @"travel_title_unique";
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
