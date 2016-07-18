//
//  ServerConnection.m
//  ProjectLoginRenewal
//
//  Created by Tedigom on 2016. 7. 4..
//  Copyright © 2016년 Tedigom. All rights reserved.
//


#import "ServerConnection.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "ViewController.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
#import "MenuSlideViewController.h"
#import "UserInfo.h"

@interface ServerConnection()


@end


@implementation ServerConnection

//- (void)authenticatewhenAutoLoginEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword
//                       completion:(void (^)(BOOL success))completionBlock
//{
//    
//    NSURL *URL = [NSURL URLWithString:@"http://52.78.72.132/login/"];
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSDictionary *params = @{@"email": userEmail,
//                             @"password": userPassword};
//    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        
//        //        if (completionBlock) {
//        completionBlock(YES);
//        //        }
//        
//        NSLog(@"Authentication Success");
//        NSLog(@"JSON: %@",responseObject);
//        
//        
//        
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        //        if (completionBlock) {
//        completionBlock(NO);
//        //        }
//        
//        NSLog(@"Authentication Failure");
//        NSLog(@"Error : %@", error);
//    }];
//
//    
//}

//Authenticate ( Login ) server Connection Method
- (void)authenticateWithUserEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword
                       completion:(void (^)(BOOL success))completionBlock{
    
    
    NSURL *URL = [NSURL URLWithString:@"http://52.78.72.132/login/"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email": userEmail,
                             @"password": userPassword};
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        completionBlock(YES);
        
        NSLog(@"Authentication Success");
        NSLog(@"JSON: %@",responseObject);
        
        //Store Data (email, token) in UserInfo (realm)
        // ##SJ
        RLMRealm *realm = [RLMRealm defaultRealm];
        RLMResults *resultArray = [UserInfo objectsWhere:@"user_id == %@", userEmail];
        UserInfo *userinfo = nil;
        if (resultArray.count > 0) {
            // 이미 있는 데이터
            userinfo = resultArray[0];
            [realm beginWriteTransaction];
            userinfo.user_token = [responseObject objectForKey:@"token"];
            [realm commitWriteTransaction];
        } else {
            // 새로운 데이터
            userinfo = [[UserInfo alloc]init];
            userinfo.user_id = userEmail;
            userinfo.user_token = [responseObject objectForKey:@"token"];
            [realm beginWriteTransaction];
            [realm addObject:userinfo];
            [realm commitWriteTransaction];
        }
        // ##SJ End
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //        if (completionBlock) {
        completionBlock(NO);
        //        }
        
        NSLog(@"Authentication Failure");
        NSLog(@"Error : %@", error);
    }];
    
}

//send Email, and username from facebook to server and get JWT Token
-(void)sendUserInfoFromFacebook:(NSString*)email : (NSString*)userName {
    
    
    NSURL *URL = [NSURL URLWithString:@"LoginServer"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email":email,
                             @"userName": userName};
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        
        NSLog(@"facebook Info send Success");
        NSLog(@"JSON: %@",responseObject);
        
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLog(@"facebook Info send Failure");
        NSLog(@"Error : %@", error);
    }];

    
}


//Register New Eamil, and Password in server.
- (void)registerWithUserEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword completion:(void (^)(BOOL success))completionBlock
{
    NSURL *URL = [NSURL URLWithString:@"http://52.78.72.132/signup/"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email": userEmail,
                             @"password": userPassword};
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        completionBlock(YES);
        NSLog(@"Register Success");
        NSLog(@"JSON: %@",responseObject);
    }failure:^(NSURLSessionTask *operation, NSError *error) {
        completionBlock(NO);
        NSLog(@"Register fail");
        NSLog(@"Error : %@",error);
    }];
}






@end