//
//  ImageRequestObject.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "ImageRequestObject.h"

@implementation ImageRequestObject

static NSString * const imageRequestURL = @"http://52.78.72.132/create/";
static NSString * const metadataRequestURL = @"http://52.78.72.132/create/";
static NSString * const listRequestURL = @"http://52.78.72.132/list/";

// 이미지 네트워킹 싱글톤 생성
+ (instancetype)sharedInstance {
    
    static ImageRequestObject *object = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[ImageRequestObject alloc] init];
    });
    
    return object;
}

// 이미지 업로드 리퀘스트
- (void)uploadImages:(NSMutableArray *)selectedImages inTravelTitle:(NSString *)travelTitle {
    
    NSLog(@"Start Image Upload");
    
    // 업로드 parameter
    NSDictionary *parameters =  @{@"user_token":@"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InRlc3RAdC5jb20iLCJ1c2VybmFtZSI6InRlc3RAdC5jb20iLCJ1c2VyX2lkIjoxMywiZXhwIjoxNDY4NDgwOTQyLCJvcmlnX2lhdCI6MTQ2ODQ4MDY0Mn0.1vifyWdFf1ENYCz5aou9ykypRZFpUc8GkSSIYyqlTuA", @"travel_title":@"여행 이름"};
    
    // global queue 생성
    dispatch_queue_t uploadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSInteger count = [[MultiImageDataCenter sharedImageDataCenter] callSelectedImages].count;
    
    for (NSInteger i = 0; i < count; i++) {
        UIImage *image = [[MultiImageDataCenter sharedImageDataCenter] callSelectedImages][i];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.jpeg",[ [MultiImageDataCenter sharedImageDataCenter] callSelectedData][i][@"timestamp"]];
        
        dispatch_async(uploadQueue, ^{
            
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            [manager POST:imageRequestURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8)
                                            name:@"image_data"
                                        fileName:fileName
                                        mimeType:@"image/jepg"];
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"Image Uploade Success");
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Image Upload Error: %@",error);
            }];
        });
    };
    
            
//            NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
//                                                                                                      URLString:imageRequestURL
//                                                                                                     parameters:parameters
//                                                                                      constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//                                                                                          
//                                                                                          [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8)
//                                                                                                                      name:@"image_data"
//                                                                                                                  fileName:fileName
//                                                                                                                  mimeType:@"image/jpeg"];
//                                                                                      }
//                                                                                                          error:nil];
//            // upload task 생성 및 실시
//            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//            
//            NSURLSessionUploadTask *uploadTask;
//            uploadTask = [manager uploadTaskWithStreamedRequest:request
//                                                       progress:^(NSProgress * _Nonnull uploadProgress) {
//                                                           
//                                                       } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//                                                           if (error) {
//                                                           } else {
//                                                               NSLog(@"Uploaed response: %@, responseObject: %@", response, responseObject);
//                                                               if ([responseObject[@"code"] isEqualToNumber:@201]) {
//                                                                   
//                                                               }
//                                                           }
//                                                       }];
//            
//            [uploadTask resume];
            
}

// 메타데이터 업로드 리퀘스트
- (void)uploadMetaDatas:(NSMutableArray *)selectedDatas inTravelTitle:(NSString *)travelTitle  {
    
    NSLog(@"Start Metadata Upload");
    
    NSDictionary *metadataDic = @{@"travel_title":@"travel99", @"image_metadatas":selectedDatas};
    
    NSLog(@"%@",metadataDic);
    
    NSString *tokenStr = @"JWT eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMywiZW1haWwiOiJ0ZXN0QHQuY29tIiwidXNlcm5hbWUiOiJ0ZXN0QHQuY29tIiwiZXhwIjoxNDY4NTc0MzQzLCJvcmlnX2lhdCI6MTQ2ODU3MTM0M30.z4xyOEvQfEkkXBVFvb4MgfKojEf_VCuczPGHRQ5wmO0";
    
    NSLog(@"%@", tokenStr);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setValue:tokenStr forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [manager POST:metadataRequestURL parameters:metadataDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Metadata Post success!");
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Metadata Post error: %@", error);
    }];
    
    
    [self requestMetadatas];
}

// 메타데이터 받는 메소드
- (void)requestMetadatas {
    
    NSLog(@"Start get metadatas");
    
    
    NSString *tokenStr = @"JWT eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMywiZW1haWwiOiJ0ZXN0QHQuY29tIiwidXNlcm5hbWUiOiJ0ZXN0QHQuY29tIiwiZXhwIjoxNDY4NTc0MzQzLCJvcmlnX2lhdCI6MTQ2ODU3MTM0M30.z4xyOEvQfEkkXBVFvb4MgfKojEf_VCuczPGHRQ5wmO0";
    
    NSLog(@"%@", tokenStr);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    [manager.requestSerializer setValue:tokenStr forHTTPHeaderField:@"Authorization"];
    
    [manager GET:listRequestURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"get list success!");
        NSLog(@"%@", responseObject);
   
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get list Error:%@", error);
    }];
    
}

@end
