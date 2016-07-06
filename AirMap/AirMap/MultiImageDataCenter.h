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

//@property (nonatomic) PHAuthorizationStatus photoAuthoStatus;

+ (PHFetchResult *)loadFetchResult;
+ (void)moveToMultiImageSelectFrom:(UIViewController *)viewController;

@end
