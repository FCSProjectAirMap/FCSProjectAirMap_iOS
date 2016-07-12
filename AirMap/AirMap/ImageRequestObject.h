//
//  ImageRequestObject.h
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiImageDataCenter.h"
#import "AFNetworking.h"

@interface ImageRequestObject : UIView

+ (instancetype)sharedInstance;
- (void)uploadImages:(NSMutableArray *)selectedImages inTravelTitle:(NSString *)travelTitle;
- (void)uploadMetaDatas:(NSMutableArray *)selectedDatas inTravelTitle:(NSString *)travelTitle;

@end
