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
#import "LoginViewController.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
#import "MenuSlideViewController.h"
#import "UserInfo.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TravelActivation.h"
#import "AppDelegate.h"


@interface ServerConnection()



@end


@implementation ServerConnection

//Authenticate ( Login ) server Connection Method
- (void)authenticateWithUserEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword
                       completion:(void (^)(BOOL success))completionBlock{
    
    
    NSURL *URL = [NSURL URLWithString:@"https://airmap.travel-mk.com/login/"];
    
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
            
            // Activity가 Yes인 여행 경로를 싱글톤이 참조.
            for (TravelList *travelList in userinfo.travel_list) {
                if (travelList.activity) {
                    [TravelActivation defaultInstance].travelList = travelList;
                    // title noification
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTitleChange" object:travelList.travel_title];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTrackingDraw" object:nil];
                    break;
                }
            }
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
        
        NSHTTPURLResponse* r = (NSHTTPURLResponse*)operation.response;
        NSInteger errorMessage =r.statusCode;
       if(errorMessage == 0)
       {
           [[NSNotificationCenter defaultCenter] postNotificationName:@"NotierrorforNetwork" object:self userInfo:nil];

       }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notierrorlogin" object:self userInfo:nil];
       }
        
    }];
    
}

//send Email, and username from facebook to server and get JWT Token
-(void)sendUserInfoFromFacebook:(NSString*)email : (NSString*)userName {
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    
    [keychainItem setObject:email forKey:(__bridge id)kSecAttrAccount];
    
        NSURL *URL = [NSURL URLWithString:@"https://airmap.travel-mk.com/signup/"];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *params = @{@"email":email,
                                 @"password": userName};
        [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            
            NSLog(@"facebook Info send Success in first");
            NSLog(@"JSON: %@",responseObject);
            
            
            
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            
            NSLog(@"facebook Info send Failure in first");
            NSLog(@"Error : %@", error);
            NSURL *URL = [NSURL URLWithString:@"https://airmap.travel-mk.com/login/"];
            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            NSDictionary *params = @{@"email":email,
                                     @"password": userName};
            [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                
                NSLog(@"facebook Info send Success in use");
                NSLog(@"JSON: %@",responseObject);
                
                
                
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                
                NSLog(@"facebook Info send Failure in use");
                NSLog(@"Error : %@", error);
            }];

        }];
        
        
    }




//Register New Eamil, and Password in server.
- (void)registerWithUserEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword completion:(void (^)(BOOL success))completionBlock
{
    NSURL *URL = [NSURL URLWithString:@"https://airmap.travel-mk.com/signup/"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email": userEmail,
                             @"password": userPassword};
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        completionBlock(YES);
        NSLog(@"Register Success");
        NSURL *URL2 = [NSURL URLWithString:@"https://airmap.travel-mk.com/login/"];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *params = @{@"email": userEmail,
                                 @"password": userPassword};
        [manager POST:URL2.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            NSLog(@"Authentication Success");
            NSLog(@"JSON: %@",responseObject);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Authentication Failure");
            NSLog(@"Error : %@", error);
            
            NSHTTPURLResponse* r = (NSHTTPURLResponse*)operation.response;
            NSInteger errorMessage =r.statusCode;
            if(errorMessage == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotierrorforNetwork" object:self userInfo:nil];
                
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Notierrorlogin" object:self userInfo:nil];
            }
            
        }];

    }failure:^(NSURLSessionTask *operation, NSError *error) {
        completionBlock(NO);
        NSLog(@"Register fail");
        NSLog(@"니가원하는 Error : %@",error);

        
        
        NSHTTPURLResponse* r = (NSHTTPURLResponse*)operation.response;
        NSInteger errorMessage =r.statusCode;
        if(errorMessage == 500 || errorMessage == 403)
        {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"Notierrorcontains500" object:self userInfo:nil];
            
        }else{
             [[NSNotificationCenter defaultCenter] postNotificationName:@"NotierrorfortheotherThing" object:self userInfo:nil];
        }
        }];
}






@end