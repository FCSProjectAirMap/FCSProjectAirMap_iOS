//
//  MultiImageDataCenter.h
//  PhotoCollectionTest
//
//  Created by Mijeong Jeon on 7/4/16.
//  Copyright © 2016 Mijeong Jeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MultiImageCollectionViewController.h"
#import "ToastView.h"

@interface MultiImageDataCenter : NSObject

@property (strong, nonatomic) PHFetchResult *fetchResult;

+ (instancetype)sharedImageDataCenter;
- (void)moveToMultiImageSelectFrom:(UIViewController *)viewController;

- (void)addAsset;
- (void)removeAsset;
- (NSMutableArray *)callSelectedImages;

@end
