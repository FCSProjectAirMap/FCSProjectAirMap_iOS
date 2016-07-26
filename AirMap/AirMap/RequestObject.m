//
//  RequestObject.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "RequestObject.h"

@interface RequestObject ()

@property (strong, nonatomic) NSString *JWTToken;
@property (strong, nonatomic) UserInfo *userInfo;
@property (strong, nonatomic) NSString *user_id;
@end

@implementation RequestObject

static NSString * const imageUploadURL = @"https://airmap.travel-mk.com/api/travel/create_image/";
static NSString * const metadataUploadURL = @"https://airmap.travel-mk.com/api/travel/create/";
static NSString * const listRequestURL = @"https://airmap.travel-mk.com/api/travel/list/";
static NSString * const detailRequestURL = @"https://airmap.travel-mk.com/api/travel/detail/";

// 이미지 네트워킹 싱글톤 생성
+ (instancetype)sharedInstance {
    
    static RequestObject *object = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[RequestObject alloc] init];
    });
    
    return object;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 현재 로그인 중인 회원의 아이디값 가져오기
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
        NSString *keyChainUser_id = [keychainItem objectForKey: (__bridge id)kSecAttrAccount];
        //현재 로그인 중인 회원정보 가져오기
        RLMResults *resultArray = [UserInfo objectsWhere:@"user_id == %@", keyChainUser_id];
        self.userInfo = resultArray[0];
        // @앞 아이디가져오기
        NSArray *idArray = [self.userInfo.user_id componentsSeparatedByString:@"@"];
        self.user_id = [idArray firstObject];
        NSLog(@"%@", self.user_id);
        // 토큰값 가져오기
        self.JWTToken = [@"JWT " stringByAppendingString:self.userInfo.user_token];
        NSLog(@"%@", self.JWTToken);
    }
    return self;
}

// 이미지 업로드 리퀘스트
- (void)uploadSelectedImages:(NSMutableArray *)selectedImages withSelectedData:(NSMutableArray *)selectedData {
    
    NSLog(@"Start Image Upload");
    
    // 업로드 parameter
    NSDictionary *parameters =  @{@"travel_title":[TravelActivation defaultInstance].travelList.travel_title_unique};
    
    // global queue 생성
    //    dispatch_queue_t uploadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 네트워킹을 위한 AFHTTPSettion Manager 생성, JWTToken 값으로 접근 권한 설정
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    // 선택된 사진 수만큼 사진 전송
    NSInteger count = selectedImages.count;
    
    for (NSInteger i = 0; i < count; i++) {
        // 이미지 파일
        UIImage *image = selectedImages[i];
        // 파일 이름을 uer_id_travel_title_unique_timestamp.jpeg로 저장
        NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@.jpeg", self.user_id, [TravelActivation defaultInstance].travelList.travel_title_unique, selectedData[i][@"timestamp"]];
        
        //        dispatch_async(uploadQueue, ^{
        // 큐내에서 POST로 이미지 한장씩 비동기로 전달
        [manager POST:imageUploadURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8)
                                        name:@"image_data"
                                    fileName:fileName
                                    mimeType:@"image/jepg"];
            NSLog(@"%@", fileName);
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"Image Uploade Success");
            [self requestTravelList];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Image Upload Error: %@",error);
        }];
        //        });
    };
}

// 메타데이터 업로드 리퀘스트
- (void)uploadSelectedMetaDatas:(NSMutableArray *)selectedDatas withSelectedImages:(NSMutableArray *)selectedImages {
    
    NSLog(@"Start Metadata Upload");
    
    NSDictionary *metadataDic = @{@"travel_title":[TravelActivation defaultInstance].travelList.travel_title_unique, @"image_metadatas":selectedDatas};
    
    NSLog(@"%@", metadataDic);
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    [manager POST:metadataUploadURL parameters:metadataDic
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSLog(@"Metadata Post success!");
              [self uploadSelectedImages:selectedImages withSelectedData:selectedDatas];
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Metadata Post error: %@", error);
              
              //              if (i < 3) {
              //                  [self uploadMetaDatas:selectedDatas withSelectedImages:selectedImages];
              //                  i ++;
              //              }
          }];
}

// 여행경로 리스트 받기
- (void)requestTravelList {
    
    NSLog(@"Start get metadatas");
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    [manager GET:listRequestURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"get list success!");
        NSLog(@"%@", responseObject);
        [self saveTitleListWithResponseObject:responseObject];
        [self requestDetailMetadatas];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get list Error:%@", error);
    }];
}

// 특정 id에 저장된 세부 메타데이터 받기
- (void)requestDetailMetadatas {
    
    NSLog(@"Start get detail metadatas");
    
    NSString *idNumber = [TravelActivation defaultInstance].travelList.id_number;
    NSString *numberString = [NSString stringWithFormat:@"%@/", idNumber];
    NSString *urlString = [detailRequestURL stringByAppendingString:numberString];
    NSLog(@"%@",urlString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    [manager GET:urlString  parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"get detail success!");
        NSLog(@"%@", responseObject);
        
        [self saveDetailDataWithResponseObject:responseObject];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get detail Error:%@", error);
    }];
}

- (void)saveTitleListWithResponseObject:(id)responseObject {
    
    NSArray *responseArray = [NSArray arrayWithArray:responseObject];
    
    // Realm에 기존에 저장되어있는 값 가져오기
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSInteger count = self.userInfo.travel_list.count;
    NSMutableArray *travelArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    if (count != 0) {
        for (NSInteger i = 0; i < count; i++) {
            TravelList *travelList = self.userInfo.travel_list[i];
            [travelArray addObject:[NSString stringWithFormat:@"%@", travelList.id_number]];
        }
    }
    NSLog(@"travelListinrealm:%@", travelArray);
    
    // Realm에 저장되어있는 id값 비교해서 서버에있는 새로운내용만 Reaml에 저장
    for (NSInteger i = 0; i < responseArray.count; i++) {
        NSString *idNumber = [NSString stringWithFormat:@"%@",[responseArray[i] objectForKey:@"id"]];
        if (![travelArray containsObject:idNumber]) {
            
            TravelList *travelList = [[TravelList alloc] init];
            NSArray *subTitleArray = [[responseObject[i] objectForKey:@"travel_title"] componentsSeparatedByString:@"_"];
            travelList.travel_title = [subTitleArray firstObject];
            travelList.travel_title_unique = [responseArray[i] objectForKey:@"travel_title"];
            travelList.id_number = [NSString stringWithFormat:@"%@", [responseArray[i] objectForKey:@"id"]];

            // realm DB에 metadata 저장
            [realm beginWriteTransaction];
//            [realm addOrUpdateObject:travelList];
            [self.userInfo.travel_list addObject:travelList];
            [realm commitWriteTransaction];
        }
    }
}

- (void)saveDetailDataWithResponseObject:(id)responseObject {
    
    NSArray *responseArray = [NSArray arrayWithArray:responseObject];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for (NSInteger i = 0; i < responseArray.count; i++) {
        
        ImageData *imageData = [[ImageData alloc] init];
        imageData.timezone_date = [responseArray[i] objectForKey:@"created_date"];
        imageData.country = [responseObject[i] objectForKey:@"country"];
        imageData.city = [responseObject[i] objectForKey:@"city"];
        imageData.country = [responseObject[i] objectForKey:@"country"];
        imageData.image_url = [responseObject[i] objectForKey:@"travel_image"];
        
        // realm DB에 detatil metadata 저장
        [realm beginWriteTransaction];
        [[TravelActivation defaultInstance].travelList.image_datas addObject:imageData];
        [realm commitWriteTransaction];
    }
}


@end
