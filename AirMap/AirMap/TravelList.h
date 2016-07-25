//
//  TravelList.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 14..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <Realm/Realm.h>
#import "ImageData.h"

@interface TravelList : RLMObject

@property NSString *travel_title;
@property NSString *travel_title_unique;
@property NSString *id_number;
@property BOOL activity;
@property RLMArray<ImageData> *image_datas;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<TravelList>
RLM_ARRAY_TYPE(TravelList)
