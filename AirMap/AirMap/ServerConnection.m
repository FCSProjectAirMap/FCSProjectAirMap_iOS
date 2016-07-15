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

//#import <AFNetworking/AFHTTPSessionManager.h>

@interface ServerConnection()


@end


@implementation ServerConnection

-(void)loginRequest
{
    //    NSMutableURLRequest *request = nil;
    //    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://Server"]];
    //
    //    NSString *post = [NSString stringWithFormat:@"ID=%@&PIN=%@", @"username", @"password"];
    //    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    //    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    //    [request setTimeoutInterval: 15];
    //    [request setHTTPMethod:@"POST"];
    //    [request setHTTPBody:postData];
    //
    //
    //    NSURLSession *session = [NSURLSession sharedSession];
    //    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    //                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    //                                      {
    //                                          // do something with the data
    //                                      }];
    //    [dataTask resume];
}

- (void)authenticatewhenAutoLoginEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword
                       completion:(void (^)(BOOL success))completionBlock
{
    
    NSURL *URL = [NSURL URLWithString:@"http://52.78.72.132/login/"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email": userEmail,
                             @"password": userPassword};
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        //        if (completionBlock) {
        completionBlock(YES);
        //        }
        
        NSLog(@"Authentication Success");
        NSLog(@"JSON: %@",responseObject);
        
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //        if (completionBlock) {
        completionBlock(NO);
        //        }
        
        NSLog(@"Authentication Failure");
        NSLog(@"Error : %@", error);
    }];

    
}


- (void)authenticateWithUserEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword
                       completion:(void (^)(BOOL success))completionBlock{
    
    
    NSURL *URL = [NSURL URLWithString:@"http://52.78.72.132/login/"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email": userEmail,
                             @"password": userPassword};
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        //        if (completionBlock) {
        completionBlock(YES);
        //        }
        
        NSLog(@"Authentication Success");
        NSLog(@"JSON: %@",responseObject);
        
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //        if (completionBlock) {
        completionBlock(NO);
        //        }
        
        NSLog(@"Authentication Failure");
        NSLog(@"Error : %@", error);
    }];
    
}

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



- (void)registerWithUserEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword
{
    NSURL *URL = [NSURL URLWithString:@"http://52.78.72.132/signup/"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = @{@"email": userEmail,
                             @"password": userPassword};
    [manager POST:URL.absoluteString parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"Register Success");
        NSLog(@"JSON: %@",responseObject);
    }failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Register fail");
        NSLog(@"Error : %@",error);
    }];
}





@end