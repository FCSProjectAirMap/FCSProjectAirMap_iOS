//
//  RequestObject.h
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiImageDataCenter.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"

@interface RequestObject : UIView

@property (strong, nonatomic) NSString *fileNameForUnique;

+ (instancetype)sharedInstance;
// 메타데이터, 이미지 전송
- (void)uploadSelectedMetaDatas:(NSMutableArray *)selectedDatas withSelectedImages:(NSMutableArray *)selectedImages;
// 로그인 성공시 서버에 저장된 모든 여행경로 불러오기(+ id)
- (void)requestTravelList;

@end
