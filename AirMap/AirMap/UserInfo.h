//
//  UserInfo.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 14..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <Realm/Realm.h>
#import "TravelList.h"

@interface UserInfo : RLMObject

@property NSString *user_id;
@property NSString *user_name;
@property NSString *token;
@property RLMArray<TravelList> *travel_list;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<UserInfo>
RLM_ARRAY_TYPE(UserInfo)
