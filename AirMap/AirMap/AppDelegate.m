//
//  AppDelegate.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 5..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <FBSDKCorekit/FBSDKCorekit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MapViewController.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
#import "ServerConnection.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // google map API key
    [GMSServices provideAPIKey:kAPIKey];
    
    // Facebook Login API
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    // Set MapViewController to RootViewController
    MapViewController *mapViewController = [[MapViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = mapViewController;
    
    // Check FaceBook Token and decide if LoginViewContoller Open or Close
    if ([FBSDKAccessToken currentAccessToken]) {
//      [self showLoginView];
    } else {
        // display the login page.
        [self showLoginView];
    }

    [self.window makeKeyAndVisible];
    
    // Realm
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 8;
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
//    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:loginViewController];
//    navigationController.
    
    return YES;
}



- (void)showLoginView
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    
    //Set Keychain, and match ID & Password in Server and decide to present LoginViewController
    if([keychainItem objectForKey: (__bridge id)kSecAttrAccount] && [keychainItem objectForKey:(__bridge id)kSecValueData])
    {
        NSData *pass =[keychainItem objectForKey:(__bridge id)(kSecValueData)];
        NSString *passworddecoded = [[NSString alloc] initWithData:pass
                                                          encoding:NSUTF8StringEncoding];
        ServerConnection *serverConnection = [[ServerConnection alloc]init];
        [serverConnection authenticateWithUserEmail:[keychainItem objectForKey: (__bridge id)kSecAttrAccount] withUserPassword:passworddecoded completion:^(BOOL success) {
            NSLog(@"오토로그인 구동");
            if (success) {
                NSLog(@"오토로그인 석세스");
            } else {
                NSLog(@"오토로그인 fa일");
                // Check ID & Password in Keychain, and if autoLogin is failed, Present the LoginViewController
                ViewController *loginViewController = [[ViewController alloc]init];
                [self.window makeKeyAndVisible];
                loginViewController.modalPresentationStyle = UIModalPresentationPopover;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginViewController];
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
            }
        }];

    }
    else
    {
        ViewController *loginViewController = [[ViewController alloc]init];
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:loginViewController animated:YES completion:NULL];

    }
}




//add method for facebook login
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
