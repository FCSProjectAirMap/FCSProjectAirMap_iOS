//
//  ViewController.m
//  ProjectLoginRenewal
//
//  Created by Tedigom on 2016. 7. 4..
//  Copyright © 2016년 Tedigom. All rights reserved.
//

/******************************************************************
 ****************                                 *****************
 ****************      LOGIN  VIEWCONTROLLER      *****************
 ****************                                 *****************
 *****************************************************************/

#import "AppDelegate.h"
#import "ViewController.h"
#import "SignUpViewController.h"
#import "ServerConnection.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MapViewController.h"




@interface ViewController ()<UITextFieldDelegate>{
   
    // information fetched from facebook Login
    NSString *name;
    NSString *email;
    NSString *accessToken;
    
    int facebook_login;
}

@property (weak, nonatomic)  UITextField *emailField;
@property (weak, nonatomic)  UITextField *passWordField;

@property (weak, nonatomic)  UIButton *facebookLoginButton;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden: YES];
    
    // NSUserDefaults for user autologin(Temporary)
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if(![userDefault boolForKey:@"registered"]){
        NSLog(@"No user registered");
        
        //        [self alertStatus:@"Not registered" :@"Alert" :1];
    }else{
        NSLog(@"User registered");
    }
    
//    Background image
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ryan10.png"]];
    [backgroundView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:backgroundView];
    
   
//    emaillabel//passwordlabel
    const CGFloat VIEW_MARGIN = 20;
    CGSize textFieldSize = CGSizeMake(self.view.frame.size.width - VIEW_MARGIN*6, 40);
    CGSize buttonSize = CGSizeMake(80, 30);
    
    CGFloat offsetY = (self.view.frame.size.height/2)+120;
    
    UITextField *emailTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [emailTF setBackgroundColor:[UIColor whiteColor]];
    [emailTF setBorderStyle:UITextBorderStyleRoundedRect];
    [emailTF setPlaceholder:@"input email-address"];
    [self.view bringSubviewToFront:emailTF];
    self.emailField =emailTF;
    [self.view addSubview:emailTF];
    offsetY +=emailTF.frame.size.height+VIEW_MARGIN;
    
    UITextField *passwordTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [passwordTF setBorderStyle:UITextBorderStyleRoundedRect];
    [passwordTF setBackgroundColor:[UIColor whiteColor]];
    [passwordTF setPlaceholder:@"input Password"];
    [self.view bringSubviewToFront:passwordTF];
    self.passWordField = passwordTF;
    [self.view addSubview:passwordTF];
    offsetY +=passwordTF.frame.size.height+VIEW_MARGIN;
    
    [self.passWordField setSecureTextEntry:YES];
    
    
    self.emailField.delegate = self;
    self.passWordField.delegate = self;

    
//    signup, Login, LoginwithFacebook Button
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor =[UIColor darkGrayColor];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake(VIEW_MARGIN*3,offsetY,buttonSize.width,buttonSize.height)];
    [loginButton addTarget:self action:@selector(clickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
    UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signupButton.backgroundColor = [UIColor greenColor];
    [signupButton setTitle:@"SignUp" forState:UIControlStateNormal];
    [signupButton setFrame:CGRectMake(VIEW_MARGIN*4 + buttonSize.width, offsetY, buttonSize.width, buttonSize.height)];
    [signupButton addTarget:self action:@selector(clickSignUpButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signupButton];
    
    
    UIButton *facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    facebookLoginButton.backgroundColor = [UIColor blueColor];
    [facebookLoginButton setTitle:@"FaceBook" forState:UIControlStateNormal];
    [facebookLoginButton setFrame:CGRectMake(VIEW_MARGIN*5+buttonSize.width*2, offsetY, buttonSize.width, buttonSize.height)];
    [facebookLoginButton addTarget:self action:@selector(facebookLoginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookLoginButton];
    self.facebookLoginButton = facebookLoginButton;
    
//
//    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    facebookButton.backgroundColor = [UIColor darkGrayColor];
//    facebookButton.frame = CGRectMake(0, 0, 180, 40);
//    facebookButton.center = self.view.center;
//    [facebookButton setTitle:@"facebook" forState:UIControlStateNormal];
//    [facebookButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:facebookButton];
    

}

-(void)clickSignUpButton:(UIButton*)sender{
    
    SignUpViewController *signupVC = [[SignUpViewController alloc]init];
    [self presentViewController:signupVC animated:YES completion:nil];
    
    
}


//Selector method of FacebookLoginButton
-(void)facebookLoginButtonClicked
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc]init];
    [login logInWithReadPermissions:@[@"public_profile",@"user_friends",@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
        if (error) {
            NSLog(@"Process error");
        }else if(result.isCancelled){
            NSLog(@"Cancelled");
        }else{
            NSLog(@"Logged in");
            NSLog(@"Result : %@",result);
            //ACTION After Login
//            MainPageViewController *main = [[MainPageViewController alloc] init];
//            [self.navigationController pushViewController:main animated:YES];
            
            //After FBSDKLoginMangager permitted
            if([result.grantedPermissions containsObject:@"email"])
                            {
                                NSLog(@"result is %@",result);
                                // get userInformation
                                [self fetchUserInfo];
                                //Action After Login
                                [self dismissViewControllerAnimated:YES completion:nil];
                                
                            }

            
        }
    }];

    
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"/me" parameters:@{@"fields":@"id,name,email"} HTTPMethod:@"GET"];
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
//        NSLog (@"result : %@",result);
//        name = [result valueForKey:@"name"];
//        email = [result valueForKey:@"email"];
//        accessToken = [result valueForKey:@"id"];
//         ;
//    }];
    
}


//- (IBAction)clickFacebookButton:(UIButton *)sender {
//    
//    NSLog(@"button pushed");
//    
//    FBSDKLoginManager * login =[[FBSDKLoginManager alloc]init];
//    [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
//        if (error) {
//            NSLog(@"process error");
//        }else if(result.isCancelled){
//            NSLog(@"canceled");
//        }else{
//            NSLog(@"Logged in");
//            //로그인후 액션
//            MainPageViewController * mainPage = [[MainPageViewController alloc]init];
//            [self.navigationController pushViewController:mainPage animated:YES ];
//            
//            
//            if([result.grantedPermissions containsObject:@"email"])
//            {
//                NSLog(@"result is %@",result);
//                [self fetchUserInfo];
//            }
//            
//        }
//    }];
//    
//}
//
//fetch email, name from Facebook userConnection
-(void)fetchUserInfo{
    FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, email"}] ;
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc]init];
    [connection addRequest:requestMe completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
        if (result) {
            if([result objectForKey:@"email"])
            {
                NSLog(@"email : %@",[result objectForKey:@"email"]);
            }
            if([result objectForKey:@"name"])
            {
                NSLog(@"firstname : %@",[result objectForKey:@"name"]);
            }
            if([result objectForKey:@"id"])
            {
                NSLog(@"user id : %@",[result objectForKey:@"id"]);
            }
            ServerConnection *serverConnection = [[ServerConnection alloc]init];
            [serverConnection sendUserInfoFromFacebook:[result objectForKey:@"email"] :[result objectForKey:@"name"]];
            
            
            
            
//            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"http://52.78.72.132/login/"
//                                               parameters:@{ @"fields":@"id, name, email" }
//                                               HTTPMethod:@"POST"]
//             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                 if ([error.userInfo[FBSDKGraphRequestErrorGraphErrorCode] isEqual:@200]) {
//                     NSLog(@"permission error");
//                 }else{
//                     NSLog(@"LoginSuccess - facebook");
//                     NSLog(@"JSON: %@",connection);
//                     [self dismissViewControllerAnimated:YES completion:nil];
//                 }];
            
        }
    }];
    [connection start];

    
}


//alert method for easily fetch
- (void)alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:okAction];
    alert.view.tag = tag;
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

//click ordinary LoginButton method(IBAction)
- (void)clickLoginButton:(UIButton *)sender {

    ServerConnection * connection =[[ServerConnection alloc]init];
    [connection authenticateWithUserEmail:self.emailField.text
                         withUserPassword:self.passWordField.text
                               completion:^(BOOL success) {
                                   NSLog(@"구동");
                                   if (success) {
                                       NSLog(@"석세스");
                                       
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                       
                                   } else {
                                       NSLog(@"fa일");
                                       
                                       [self alertStatus:@"Login failed\n check your ID & Password again" :@"Error" :1];
                                       
                                       
                                   }
                               }];
    
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
       
        CGRect newFrame = self.view.frame;
        newFrame.origin.y -=100;
        self.view.frame = newFrame;
        
    }];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect newFrame = self.view.frame;
        newFrame.origin.y +=100;
        self.view.frame = newFrame;
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end