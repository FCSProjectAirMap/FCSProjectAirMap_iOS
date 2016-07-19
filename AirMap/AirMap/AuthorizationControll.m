//
//  AuthorizationControll.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "AuthorizationControll.h"

@implementation AuthorizationControll

static NSString * const photoAuthoMessege = @"[설정] > [TravelMaker] > [사진] 접근을 허용해 주세요.\n 이곳을 누르면 설정화면으로 이동합니다.";


#pragma mark - CheckPHAuthorizationState
// 앨범 접근 가능여부 확인하고 앨범으로 이동
+ (void)moveToMultiImageSelectFrom:(UIViewController *)viewController {
    
    MultiImageCollectionViewController *multiImageView = [[MultiImageCollectionViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:multiImageView];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
            // 승인 되어있을때_앨범 불러옴
        case PHAuthorizationStatusAuthorized: {
            [viewController presentViewController:navigationController animated:YES completion:^{
                
            }];
            break;
        }
            // 승인 거절되었을때_설정창으로 보내는 토스트창 띄움
        case PHAuthorizationStatusDenied: {
            [ToastView showToastInView:[[UIApplication sharedApplication] keyWindow] withMessege:photoAuthoMessege];
            break;
        }
            // 결정되지 않았을때(처음 실행)_사진 허용 알럿창으로 승인 요청
        case PHAuthorizationStatusNotDetermined: {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        [viewController presentViewController:navigationController animated:YES completion:^{
                            
                        }];
                    } else {

                    }
                }];
            break;
        }
            // PHAuthorizationStatusRestricted 경우
        default: {
            NSLog(@"restricted");
            break;
        }

    }
}

@end
