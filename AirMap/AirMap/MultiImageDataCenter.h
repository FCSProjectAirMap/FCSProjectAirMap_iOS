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
#import "TravelActivation.h"

@interface MultiImageDataCenter : NSObject

+ (instancetype)sharedImageDataCenter;

- (void)addSelectedAsset:(PHAsset *)asset;
- (void)removeSelectedAsset:(PHAsset *)asset;
- (void)resetSelectedFiles;

- (void)saveToRealmDB;

- (PHFetchResult *)callFetchResult;
- (NSMutableArray *)callSelectedAssets;
- (NSMutableArray *)callSelectedImages;
- (NSMutableArray *)callSelectedData;
- (NSMutableArray *)callSelectedAssetsWithoutGPS;

- (void)extractMetadataFromImage;

@end
