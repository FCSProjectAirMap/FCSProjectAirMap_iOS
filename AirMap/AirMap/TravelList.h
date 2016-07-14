//
//  TravelList.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 14..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <Realm/Realm.h>
#import "ImageMetaData.h"

@interface TravelList : RLMObject

@property NSString *travel_title;
@property BOOL activity;
@property RLMArray<ImageMetaData> *image_metadatas;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<TravelList>
RLM_ARRAY_TYPE(TravelList)
