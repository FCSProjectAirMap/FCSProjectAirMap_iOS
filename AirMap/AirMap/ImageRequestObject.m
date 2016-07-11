//
//  ImageRequestObject.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "ImageRequestObject.h"

@implementation ImageRequestObject

static NSString * const imageRequestURL = @"http://ios.yevgnenll.me/api/images/";
static NSString * const metadataRequestURL = @"http://ios.yevgnenll.me/api/metadats/";



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
    
    NSLog(@"Start upload images");
    
    // 업로드 parameter
    NSDictionary *parameters = @{@"user_id":@"아이디", @"travel_title":@"여행 이름"};
    
    // Multipart request 생성
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:imageRequestURL
                                                                                             parameters:parameters
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                                                                  
                                                                                  for (UIImage *image in [[MultiImageDataCenter sharedImageDataCenter] callSelectedImages]) {
                                                                                      
                                                                                      NSString *fileName = [NSString stringWithFormat:@"%@.jpeg",[ [MultiImageDataCenter sharedImageDataCenter] callSelectedData][@"timestamp"]];
                                                                                      
                                                                                      [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.1)
                                                                                                                  name:@"image_data"
                                                                                                              fileName:fileName
                                                                                                              mimeType:@"image/jpeg"];
                                                                                      
                                                                                  }
                                                                              }
                                                                                                  error:nil];
    // upload task 생성 및 실시
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request
                                               progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@",error);
        } else {
            NSLog(@"Uploaed response: %@, responseObject: %@", response, responseObject);
            if ([responseObject[@"code"] isEqualToNumber:@201]) {
                NSLog(@"Image MultiPart Success");
                
            }
        }
    }];
    
    [uploadTask resume];
}

// 메타데이터 업로드 리퀘스트
- (void)uploadMetaDatas:(NSMutableDictionary *)selectedDatas inTravelTitle:(NSString *)travelTitle  {
    
    NSLog(@"Start upload metadatas");
    
    NSArray *metadataArray = [[NSArray alloc] initWithObjects:[[MultiImageDataCenter sharedImageDataCenter] callSelectedData], nil];
    
    NSDictionary *metadataDic = @{@"user_id":@"유저 아이디",
                                  @"travel_title":@"여행 이름",
                                  @"image_metadatas":metadataArray};
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:metadataDic];
    NSLog(@"dic:%@",metadataDic);
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURL *URL = [NSURL URLWithString:metadataRequestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request
                                                               fromData:data
                                                               progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@",error);
        } else {
            NSLog(@"Uploaed response: %@, responseObject: %@", response, responseObject);
            
            if ([responseObject[@"code"] isEqualToNumber:@201]) {
                NSLog(@"Metadata MultiPart Success");
                
            }
    }
    }];
    
    [uploadTask resume];
}

                
                                          
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     - (void)drawRect:(CGRect)rect {
     // Drawing code
     }
     */
    
    @end
