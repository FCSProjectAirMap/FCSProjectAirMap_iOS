//
//  MultiImageDataCenter.m
//  PhotoCollectionTest
//
//  Created by Mijeong Jeon on 7/4/16.
//  Copyright © 2016 Mijeong Jeon. All rights reserved.
//

#import "MultiImageDataCenter.h"
@interface MultiImageDataCenter()

@property (strong, nonatomic) PHFetchResult *fetchResult;
@property (strong, nonatomic) NSMutableArray *selectedAssets;
@property (strong, nonatomic) NSMutableDictionary *selectedData;

@end

@implementation MultiImageDataCenter

+ (instancetype)sharedImageDataCenter {
    
    static MultiImageDataCenter *sharedImageDataCenter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageDataCenter = [[MultiImageDataCenter alloc] init];
    });
    return sharedImageDataCenter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadFetchResult];
        self.selectedAssets = [[NSMutableArray alloc] initWithCapacity:1];
        self.selectedData = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

#pragma mark - ImageAssets
// 이미지 가져오기
- (void)loadFetchResult {
    // 이미지 날짜역순으로 정렬
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    
    self.fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                                           options:fetchOptions];
}

// 선택된 사진 더하기
- (void)addSelectedAsset:(PHAsset *)asset {
    if (![self.selectedAssets containsObject:asset]) {
        [self.selectedAssets addObject:asset];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateNotification"
                                                        object:[NSString stringWithFormat:@"%ld", self.selectedAssets.count]];
    
}
// 재선택된 사진 빼기
- (void)removeSelectedAsset:(PHAsset *)asset {
    [self.selectedAssets removeObject:asset];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateNotification"
                                                        object:[NSString stringWithFormat:@"%ld", self.selectedAssets.count]];
}

- (void)resetSelectedAsset {
    [self.selectedAssets removeAllObjects];
}

- (PHFetchResult *)callFetchResult {
    return self.fetchResult;
}

- (NSMutableArray *)callSelectedAssets {
    return self.selectedAssets;
}

#pragma mark - AssetToUIImage
// PHAseet -> UIImage
- (NSMutableArray *)callSelectedImages {
    NSMutableArray *selectedImages = [NSMutableArray arrayWithCapacity:self.selectedAssets.count];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous =YES;

    __block UIImage *image;
    
    for (PHAsset *asset in self.selectedAssets) {
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                          targetSize:PHImageManagerMaximumSize
                                                         contentMode:PHImageContentModeDefault
                                                             options:options
                                                       resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            image = result;
            
            [selectedImages addObject:image];
        }];
    }
    
    return selectedImages;
}

# pragma mark - ExtracMetaData
// metaData추출
- (void)extractMetadataFromImage {
    
    for (PHAsset *asset in self.selectedAssets) {
        
        NSNumber *timeStamp = [NSNumber numberWithDouble:asset.creationDate.timeIntervalSince1970];
        NSNumber *latitude = [NSNumber numberWithDouble:asset.location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:asset.location.coordinate.longitude];
        
//        NSArray *location = @[latitude, longitude];
        NSDictionary *metaData = @{@"creationDate": asset.creationDate,
                                   @"timeStamp":timeStamp,
                                   @"latitude":latitude,
                                   @"longitude":longitude};
        
        [self.selectedData setObject:metaData forKey:timeStamp];
    }
    NSLog(@"%@", self.selectedData);
}

- (NSMutableDictionary *)callSelectedData {
    return self.selectedData;
}

@end
