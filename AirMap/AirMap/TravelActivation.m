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

// 활성화된 여행을 참조하는 메서드.
- (void)travelListActivation:(TravelList *)travelList {
    // 서로 같은 객체 일 경우는 작업 할 필요가 없다. 바로 return
    if ([self.travelList isEqual:travelList])
        return;
    
    // 활성화 싱글톤 객체가 참조하고 있을 경우.
    if (self.travelList != nil) {
        
        // 참조하고있는 객체의 Activity 값을 YES에서 NO로 바꿔준다. (Realm의 값이 바뀌므로 Transation안에서 작업해야 함.)
        [[RLMRealm defaultRealm] beginWriteTransaction];
        self.travelList.activity = NO;
        [[RLMRealm defaultRealm] commitWriteTransaction];
    }
    
    // 선택된 여행의 activity 컬럼을 NO에서 YES로 바꿔준다. (Realm의 값이 바뀌므로 Transation안에서 작업해야 함.)
    [[RLMRealm defaultRealm] beginWriteTransaction];
    travelList.activity = YES;
    [[RLMRealm defaultRealm] commitWriteTransaction];
    // 싱글톤 객체가 선택된 여행을 참조한다.
    self.travelList = travelList;
}

@end
