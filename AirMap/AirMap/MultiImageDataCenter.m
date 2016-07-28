//
//  MultiImageDataCenter.m
//  PhotoCollectionTest
//
//  Created by Mijeong Jeon on 7/4/16.
//  Copyright © 2016 Mijeong Jeon. All rights reserved.
//

#import "MultiImageDataCenter.h"
@interface MultiImageDataCenter()

@property (strong, nonatomic) PHFetchResult *collectionResult;
@property (strong, nonatomic) NSMutableArray *collectionAssetResults;

//@property (strong, nonatomic) PHFetchResult *fetchResult;
@property (strong, nonatomic) NSMutableArray *selectedAssets;
@property (strong, nonatomic) NSMutableArray *selectedImages;

@property (strong, nonatomic) NSMutableArray *selectedAssetsWithGPS;
@property (strong, nonatomic) NSMutableArray *selectedAssetsWithoutGPS;

@property (strong, nonatomic) NSMutableArray *selectedMetadatasWithGPS;
@property (strong, nonatomic) NSMutableArray *selectedMetadatasWithoutGPS;

@property (strong, nonatomic) RequestObject *requsetObject;

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
        self.requsetObject = [[RequestObject alloc] init];
    }
    return self;
}

#pragma mark - ImageAssets
// 이미지 가져오기
- (void)loadFetchResult {
    
    /* 카메라롤 버전
    // 이미지 날짜역순으로 정렬
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    
    
    self.fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                                 options:fetchOptions];
     */
    
    // 이미지 날짜역순으로 정렬
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
    // 특별한 순간 가져오기
    self.collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAny options:options];
    
    self.collectionAssetResults = [[NSMutableArray alloc] initWithCapacity:self.collectionResult.count];
    
    for (PHAssetCollection *collection in self.collectionResult) {
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [self.collectionAssetResults insertObject:result atIndex:[self.collectionResult indexOfObject:collection]];
    }
    
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

//- (PHFetchResult *)callFetchResult {
//    return self.fetchResult;
//}

- (PHFetchResult *)callCollectionResult {
    return self.collectionResult;
}

- (NSMutableArray *)callCollectionAssetResutls {
    return self.collectionAssetResults;
}

//- (NSMutableArray *)callSelectedAssets {
//    return self.selectedAssets;
//}

#pragma mark - AssetToUIImage
// PHAseet -> UIImage
- (void)changeAssetToImage {
    
    NSMutableArray *selectedImages = [NSMutableArray arrayWithCapacity:self.selectedAssetsWithGPS.count];
    
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
    NSLog(@"%@", self.selectedImages);
    [self saveToRealmDB];
    [self.requsetObject uploadSelectedMetaDatas:self.selectedMetadatasWithGPS withSelectedImages:self.selectedImages];
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

//- (NSMutableArray *)callSelectedImages {
//    return self.selectedImages;
//}

# pragma mark - ExtracMetaData
// metaData추출
- (void)extractMetadataFromImage {
    
    self.selectedMetadatasWithGPS = [[NSMutableArray alloc] init];
    self.selectedMetadatasWithoutGPS = [[NSMutableArray alloc] init];

    self.selectedAssetsWithGPS = [[NSMutableArray alloc] init];
    self.selectedAssetsWithoutGPS = [[NSMutableArray alloc] init];
    
    // 중복사진 제외처리(기준 : timestamp)
    RLMArray *result = [TravelActivation defaultInstance].travelList.image_datas;
    NSInteger count = result.count;
    NSMutableArray *timestampArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    if (result != nil) {
        for (NSInteger i = 0; i < count; i++) {
            ImageData *imageData = result[i];
            [timestampArray addObject:[NSString stringWithFormat:@"%ld", imageData.timestamp]];
            NSLog(@"timestampinrealm:%ld", imageData.timestamp);
        }
    }
    
    for (PHAsset *asset in self.selectedAssets) {
        // 전송할 메타데이터 추출
        NSNumber *timestamp = [NSNumber numberWithInteger:asset.creationDate.timeIntervalSince1970];
        NSString *timestampString = [NSString stringWithFormat:@"%@", timestamp];
        NSNumber *latitude = [NSNumber numberWithDouble:asset.location.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:asset.location.coordinate.longitude];
        
        NSDictionary *metaData = @{@"timestamp":timestampString,
                                   @"latitude":latitude,
                                   @"longitude":longitude};
        
        // 위도, 경도 0, 0인 데이터 예외처리
        if ([[metaData objectForKey:@"latitude"] doubleValue] == 0.0 && [[metaData objectForKey:@"longitude"] doubleValue] == 0.0) {
            
            [self.selectedMetadatasWithoutGPS addObject:metaData];
            [self.selectedAssetsWithoutGPS addObject:asset];
            
        } else {
            if (result) {
                if ([timestampArray containsObject:[metaData objectForKey:@"timestamp"]]) {
                    NSMutableArray *duplicatedAssets = [[NSMutableArray alloc] init];
                    [duplicatedAssets addObject:asset];
                    NSLog(@"duple %@", duplicatedAssets);
                } else {
                    [self.selectedMetadatasWithGPS addObject:metaData];
                    [self.selectedAssetsWithGPS addObject:asset];
                }
            }
        }
    }
    NSLog(@"with GPS:%@", self.selectedMetadatasWithGPS);
    NSLog(@"without GPS:%@", self.selectedMetadatasWithoutGPS);
    
    if (self.selectedAssetsWithGPS.count != 0) {
        [self changeAssetToImage];
    }
}

//- (NSMutableArray *)callSelectedData {
//    return self.selectedMetadatasWithGPS;
//}

- (NSMutableArray *)callSelectedAssetsWithoutGPS {
    return self.selectedAssetsWithoutGPS;
}

# pragma mark - Reamlm

- (void)saveToRealmDB {
    
    NSLog(@"%@",[RLMRealm defaultRealm].configuration.fileURL);
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    // 현재 active되어있는 객체를 참조
    TravelActivation *travelActivation = [TravelActivation defaultInstance];
    
    // 선택된 사진의 metadata 저장
    for (NSInteger i = 0; i < self.selectedMetadatasWithGPS.count; i++) {
        
        NSData *image = UIImageJPEGRepresentation(self.selectedImages[i], 0.8);

        ImageData *imageData = [[ImageData alloc] init];
//        imageData.creation_date = [self.selectedMetadatasWithGPS[i] objectForKey:@"creationDate"] ;
        imageData.latitude = [[self.selectedMetadatasWithGPS[i] objectForKey:@"latitude"] floatValue] ;
        imageData.longitude = [[self.selectedMetadatasWithGPS[i] objectForKey:@"longitude"] floatValue];
        imageData.timestamp = [[self.selectedMetadatasWithGPS[i] objectForKey:@"timestamp"] integerValue];
        imageData.image_name_unique = [NSString stringWithFormat:@"%@_%@_%@", [RequestObject sharedInstance].userId, [TravelActivation defaultInstance].travelList.travel_title_unique,[self.selectedMetadatasWithGPS[i] objectForKey:@"timestamp"]];
        imageData.image = image;

        // realm DB에 metadata 저장
        [realm beginWriteTransaction];
        [travelActivation.travelList.image_datas addObject:imageData];
        [realm commitWriteTransaction];
    }
}

@end
