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

@property (strong, nonatomic) NSMutableArray *selectedAssetsWithGPS;
@property (strong, nonatomic) NSMutableArray *selectedAssetsWithoutGPS;

@property (strong, nonatomic) NSMutableArray *selectedMetadatasWithGPS;
@property (strong, nonatomic) NSMutableArray *selectedMetadatasWithoutGPS;

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
        
        self.selectedAssetsWithGPS = [[NSMutableArray alloc] init];
        self.selectedAssetsWithoutGPS = [[NSMutableArray alloc] init];
        
        self.selectedMetadatasWithGPS = [[NSMutableArray alloc] init];
        self.selectedMetadatasWithoutGPS = [[NSMutableArray alloc] init];
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
    [self.selectedAssetsWithGPS removeAllObjects];
    [self.selectedAssetsWithoutGPS removeAllObjects];
    [self.selectedMetadatasWithGPS removeAllObjects];
    [self.selectedMetadatasWithoutGPS removeAllObjects];
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
    
    NSMutableArray *selectedImages = [NSMutableArray arrayWithCapacity:self.selectedMetadatasWithGPS.count];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous =YES;
    
    __block UIImage *image;
    
    for (PHAsset *asset in self.selectedAssetsWithGPS) {
        
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
    
    if (ratio >= 1 ) {
        return CGSizeMake(imageShortLength * ratio, imageShortLength);
    } else {
        return CGSizeMake(imageShortLength, imageShortLength / ratio);
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
        
        NSDictionary *metaData = @{@"creationDate": creationDate,
                                   @"timestamp":timestamp,
                                   @"latitude":latitude,
                                   @"longitude":longitude};
        
        // 위도, 경도 0, 0인 데이터 예외처리
        if ([[metaData objectForKey:@"latitude"] doubleValue] == 0.0 && [[metaData objectForKey:@"longitude"] doubleValue] == 0.0) {
            [self.selectedMetadatasWithoutGPS addObject:metaData];
            [self.selectedAssetsWithoutGPS addObject:asset];
        } else {
            [self.selectedMetadatasWithGPS addObject:metaData];
            [self.selectedAssetsWithGPS addObject:asset];
        }
    }
    [self changeAssetToImage];
    NSLog(@"with GPS:%@", self.selectedMetadatasWithGPS);
    NSLog(@"without GPS:%@", self.selectedMetadatasWithoutGPS);
}

- (NSMutableArray *)callSelectedData {
    return self.selectedMetadatasWithGPS;
}

- (NSMutableArray *)callSelectedAssetsWithoutGPS {
    return self.selectedAssetsWithoutGPS;
}

# pragma mark - Reamlm

- (void)saveToRealmDB {
    
    NSLog(@"%@", [RLMRealm defaultRealm].configuration.fileURL);
    
    TravelActivation *travelActivation = [TravelActivation defaultInstance];
    
    for (NSInteger i = 0; i < self.selectedMetadatasWithGPS.count; i++) {
        
        ImageData *imageData = [[ImageData alloc] init];
        imageData.creation_date = [self.selectedMetadatasWithGPS[i] objectForKey:@"creationDate"] ;
        imageData.latitude = [[self.selectedMetadatasWithGPS[i] objectForKey:@"latitude"] floatValue] ;
        imageData.longitude = [[self.selectedMetadatasWithGPS[i] objectForKey:@"longitude"] floatValue];
        imageData.timestamp = [[self.selectedMetadatasWithGPS[i] objectForKey:@"timestamp"] floatValue];
        
        [travelActivation.travelList.image_metadatas addObject:imageData];
    }
    
    UserInfo *userInfo = [[UserInfo alloc] init];
    
    [userInfo.travel_list addObject:travelActivation.travelList];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:userInfo];
    [realm commitWriteTransaction];
}

@end
