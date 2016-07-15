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
@property (strong, nonatomic) NSMutableArray *selectedImages;
@property (strong, nonatomic) NSMutableArray *selectedDatas;

@end

@implementation MultiImageDataCenter

const CGFloat imageShortLength = 640;

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
        self.selectedAssets = [[NSMutableArray alloc] init];
        self.selectedDatas = [[NSMutableArray alloc] init];
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

- (void)resetSelectedFiles {
    [self.selectedAssets removeAllObjects];
    [self.selectedImages removeAllObjects];
    [self.selectedDatas removeAllObjects];
}

- (PHFetchResult *)callFetchResult {
    return self.fetchResult;
}

- (NSMutableArray *)callSelectedAssets {
    return self.selectedAssets;
}

#pragma mark - AssetToUIImage
// PHAseet -> UIImage
- (void)changeAssetToImage {
    
    NSMutableArray *selectedImages = [NSMutableArray arrayWithCapacity:self.selectedAssets.count];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous =YES;
    
    __block UIImage *image;
    
    for (PHAsset *asset in self.selectedAssets) {
        
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                          targetSize:[self resizeAsset:asset]
                                                         contentMode:PHImageContentModeDefault
                                                             options:options
                                                       resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                           image = result;

                                                           [selectedImages addObject:image];
                                                       }];
    }
    
    self.selectedImages = selectedImages;
}

// 이미지 사이즈 변경(짧은 길이를 imageShortLength으로 맞춤, aspect fit)
- (CGSize)resizeAsset:(PHAsset *)asset {
    
    CGFloat ratio = (CGFloat) asset.pixelWidth / asset.pixelHeight;
    
    if (ratio > 1 ) {
        return CGSizeMake(imageShortLength * ratio, imageShortLength);
    } else if (ratio < 1) {
        return CGSizeMake(imageShortLength, imageShortLength / ratio);
    } else {
        return CGSizeMake(imageShortLength, imageShortLength);
    }
}

- (NSMutableArray *)callSelectedImages {
    return self.selectedImages;
}

# pragma mark - ExtracMetaData
// metaData추출
- (void)extractMetadataFromImage {
    
    for (PHAsset *asset in self.selectedAssets) {
        // 전송할 메타데이터 추출
        NSNumber *timestamp = [NSNumber numberWithDouble:asset.creationDate.timeIntervalSince1970];
        NSNumber *latitude = [NSNumber numberWithDouble:asset.location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:asset.location.coordinate.longitude];
        NSString *creationDate = [[NSString stringWithFormat:@"%@",asset.creationDate] substringToIndex:19];
//        NSData *creationDate = (NSData *)asset.creationDate;
        //        NSArray *location = @[latitude, longitude];
        NSDictionary *metaData = @{@"creationDate": creationDate,
                                   @"timestamp":timestamp,
                                   @"latitude":latitude,
                                   @"longitude":longitude};
        
        [self.selectedDatas addObject:metaData];
    }
    [self changeAssetToImage];
    NSLog(@"%@", self.selectedDatas);
}

- (NSMutableArray *)callSelectedData {
    return self.selectedDatas;
}

# pragma mark - Reamlm

- (void)saveToReamlmDB {
    NSLog(@"%@", [RLMRealm defaultRealm].configuration.fileURL);
    
    TravelList *travelList = [[TravelList alloc] init];
    travelList.travel_title = @"유럽 여행";
    travelList.activity = YES;

    for (NSInteger i = 0; i < self.selectedDatas.count; i++) {
    
    ImageMetaData *imageMetaData = [[ImageMetaData alloc] init];
    imageMetaData.creation_date = [self.selectedDatas[i] objectForKey:@"creationDate"] ;
    imageMetaData.latitude = [[self.selectedDatas[i] objectForKey:@"latitude"] floatValue] ;
    imageMetaData.longitude = [[self.selectedDatas[i] objectForKey:@"longitude"] floatValue];
    imageMetaData.timestamp = [[self.selectedDatas[i] objectForKey:@"timestamp"] floatValue];
        
        [travelList.image_metadatas addObject:imageMetaData];
    }
    
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo.user_id = @"travelMaker@gmail.com";
    userInfo.user_name = @"TM";
    userInfo.user_token = @"token";
    [userInfo.travel_list addObject:travelList];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:userInfo];
    [realm commitWriteTransaction];
}

@end
