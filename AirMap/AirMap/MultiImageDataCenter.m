//
//  MultiImageDataCenter.m
//  PhotoCollectionTest
//
//  Created by Mijeong Jeon on 7/4/16.
//  Copyright © 2016 Mijeong Jeon. All rights reserved.
//

#import "MultiImageDataCenter.h"

@implementation MultiImageDataCenter

+ (PHFetchResult *)loadFetchResult {
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                                           options:fetchOptions];
    
    return fetchResult;
}

// 앨범 접근 가능여부 확인하고 앨범으로 이동
+ (void)moveToMultiImageSelectFrom:(UIViewController *)viewController {
    
    // 앨범화면으로 넘어가기
//    MapViewController *MapView = [[MapViewController alloc] init]
    MultiImageCollectionViewController *multiImageView = [[MultiImageCollectionViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:multiImageView];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
            // 승인 되어있을때_앨범 불러옴
        case PHAuthorizationStatusAuthorized:
            [viewController presentViewController:navigationController animated:YES completion:^{
                
            }];
            break;
            // 승인 거절되었을때_설정창으로 보내는 토스트창 띄움
        case PHAuthorizationStatusDenied:
                [ToastView showToastInView:[[UIApplication sharedApplication] keyWindow]];
            break;
            // 결정되지 않았을때(처음 실행)_앨범 화면으로 이동
        case PHAuthorizationStatusNotDetermined:
            [viewController presentViewController:navigationController animated:YES completion:^{
                
            }];
            break;
            
        default:
            
            break;
    }
}

@end
