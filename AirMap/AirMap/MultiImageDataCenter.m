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
@property (strong, nonatomic) NSMutableArray *selectedImages;
@property (strong, nonatomic) NSMutableDictionary *metaData;
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
        self.selectedImages = [[NSMutableArray alloc] initWithCapacity:1];
        self.selectedData = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.metaData = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

#pragma mark - ImageSelect
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
    if (![self.selectedImages containsObject:asset]) {
        [self.selectedImages addObject:asset];
    }
    
}
// 재선택된 사진 빼기
- (void)removeSelectedAsset:(PHAsset *)asset {
    [self.selectedImages removeObject:asset];
}

- (void)resetSelectedAsset {
    
}


- (PHFetchResult *)callFetchResult {
    return self.fetchResult;
}

- (NSMutableArray *)callSelectedImages {
    
    return self.selectedImages;
}

# pragma mark - ExtracMetaData
- (void)extractMetadataFromImage {
    
    for (PHAsset *asset in self.selectedImages) {
        
        NSNumber *timeStamp = [NSNumber numberWithDouble:asset.creationDate.timeIntervalSince1970];
        NSNumber *latitude = [NSNumber numberWithDouble:asset.location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:asset.location.coordinate.longitude];
        
        NSArray *location = @[latitude, longitude];
        
        [self.metaData setObject:asset.creationDate forKey:@"creatoinDate"];
        [self.metaData setObject:timeStamp forKey:@"timeStamp"];
        [self.metaData setObject:location forKey:@"location"];
            
            [self.selectedData setObject:self.metaData forKey:timeStamp];
    }
    NSLog(@"%@", self.selectedData);
}

@end
