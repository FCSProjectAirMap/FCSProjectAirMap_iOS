//
//  ServerConnection.h
//  ProjectLoginRenewal
//
//  Created by Tedigom on 2016. 7. 4..
//  Copyright © 2016년 Tedigom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerConnection : NSObject

- (void)authenticateWithUserEmail:(NSString *)userEmail
                 withUserPassword:(NSString *)userPassword
                       completion:(void (^)(BOOL success))completionBlock;
- (void)registerWithUserEmail:(NSString *)userEmail withUserPassword:(NSString *)userPassword;
-(void)sendUserInfoFromFacebook:(NSString*)email : (NSString*)userPassword;

@end
