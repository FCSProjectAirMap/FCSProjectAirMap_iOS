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

+ (instancetype)sharedInstance;

- (void)uploadSelectedMetaDatas:(NSMutableArray *)selectedDatas withSelectedImages:(NSMutableArray *)selectedImages;

@end
