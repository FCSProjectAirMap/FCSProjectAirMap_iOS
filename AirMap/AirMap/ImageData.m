//
//  ImageMetaData.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 14..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "ImageData.h"

@implementation ImageData

// Specify default values for properties

// primary key 생성.
+ (NSString *)primaryKey {
    return @"image_name_unique";
}

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
