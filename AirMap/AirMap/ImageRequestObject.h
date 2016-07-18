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
#import "KeychainItemWrapper.h"

@interface ImageRequestObject : UIView

+ (instancetype)sharedInstance;
- (void)uploadImages:(NSMutableArray *)selectedImages;
- (void)uploadMetaDatas:(NSMutableArray *)selectedDatas;

@end
