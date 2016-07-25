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
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "UserInfo.h"




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

@property (weak, nonatomic) UIButton *loginButton;
@property (weak,nonatomic) UIButton *signupButton;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden: YES];
    
    //    Background image
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ryan10.png"]];
//    [backgroundView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.view addSubview:backgroundView];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:225/255.0 blue:0/255.0 alpha:1.0f]];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    const CGFloat VIEW_MARGIN = 20*screenWidth/375;
    
    UIImageView *imageIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"TravelMakerIcon.png"]];
    imageIcon.contentMode = UIViewContentModeScaleAspectFit;
    [imageIcon setFrame:CGRectMake(self.view.frame.size.width/2 -50*screenWidth/375, self.view.frame.size.height/2 - 180*screenWidth/375, 110*screenWidth/375, 110*screenWidth/375)];
    [self.view addSubview:imageIcon];
    
   //    emailTextField & passwordTextField Setting
  
    CGSize textFieldSize = CGSizeMake(self.view.frame.size.width - VIEW_MARGIN*6, 40);
    CGSize buttonSize = CGSizeMake(self.view.frame.size.width - VIEW_MARGIN*6, self.view.frame.size.width/7 - VIEW_MARGIN*6/7);
    
    CGFloat offsetY = (self.view.frame.size.height/2)+20;
    
     CGFloat fontSize = 30;
    
    UITextField *emailTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [emailTF setBackgroundColor:[UIColor clearColor]];
    [emailTF setBorderStyle:UITextBorderStyleNone];
    [emailTF setPlaceholder:@"Email"];
    [emailTF setFont:[UIFont fontWithName:@"NanumGothic.otf" size:fontSize]];
    [self.view bringSubviewToFront:emailTF];
    self.emailField =emailTF;
    [self.view addSubview:emailTF];
    [emailTF setKeyboardType:UIKeyboardTypeEmailAddress];
    offsetY +=emailTF.frame.size.height;
   
    //line under email textField
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_MARGIN*3, offsetY-7*screenWidth/375, self.emailField.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:60/255.0 green:30/255.0 blue:30/255.0 alpha:0.6f];
    [self.view addSubview:lineView];

    
    UITextField *passwordTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [passwordTF setBorderStyle:UITextBorderStyleNone];
    [passwordTF setBackgroundColor:[UIColor clearColor]];
    [passwordTF setPlaceholder:@"Password"];
    [passwordTF setFont:[UIFont fontWithName:@"NanumGothic.otf" size:fontSize]];
    [self.view bringSubviewToFront:passwordTF];
    self.passWordField = passwordTF;
    [self.view addSubview:passwordTF];
    offsetY +=passwordTF.frame.size.height;
    
    [self.passWordField setSecureTextEntry:YES];
    
    //line under passwordTextField
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_MARGIN*3, offsetY-7*screenWidth/375, self.passWordField.frame.size.width, 1)];
    lineView2.backgroundColor = [UIColor colorWithRed:60/255.0 green:30/255.0 blue:30/255.0 alpha:0.6f];
    [self.view addSubview:lineView2];
    offsetY +=VIEW_MARGIN;
    
    
    self.emailField.delegate = self;
    self.passWordField.delegate = self;
    
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passWordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passWordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    

//  Make buttonView contains buttons (signup,Login,LoginWithFacebook)
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, offsetY+VIEW_MARGIN, self.view.frame.size.width, self.view.frame.size.height-offsetY)];
    [buttonView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:buttonView];
    

    //    signup, Login, LoginwithFacebook Button setting
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"EmailLoginIcon.png"] forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake(VIEW_MARGIN*3,0,buttonSize.width,buttonSize.height)];
    [loginButton addTarget:self action:@selector(clickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton = loginButton;
    [buttonView addSubview:loginButton];
    
    UIButton *facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"FaceBookLoginIcon.png"] forState:UIControlStateNormal];
    [facebookLoginButton setFrame:CGRectMake(VIEW_MARGIN*3,buttonSize.height+VIEW_MARGIN/1.5, buttonSize.width, buttonSize.height)];
    [facebookLoginButton addTarget:self action:@selector(facebookLoginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:facebookLoginButton];
    
    
    UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signupButton.backgroundColor = [UIColor clearColor];
    [signupButton setTitle:@"회원가입" forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor colorWithRed:60/255.0 green:30/255.0 blue:30/255.0 alpha:0.6f] forState:UIControlStateNormal];
    [signupButton setFrame:CGRectMake(self.view.frame.size.width-70*screenWidth/375,self.view.frame.size.height-30*screenWidth/375, 60, 20)];
    [signupButton.titleLabel setFont:[UIFont fontWithName:@"NanumGothic.otf" size:fontSize]];
    signupButton.titleLabel.font =[UIFont systemFontOfSize:14.0f];
    [signupButton addTarget:self action:@selector(clickSignUpButton:) forControlEvents:UIControlEventTouchUpInside];
    signupButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    signupButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.signupButton = signupButton;
    [self.view addSubview:signupButton];
    
    

    

    
    

}

#pragma mark Action Method
// Selector Method of SignUp button
-(void)clickSignUpButton:(UIButton*)sender{
    
    SignUpViewController *signupVC = [[SignUpViewController alloc]init];
    [self.navigationController pushViewController:signupVC animated:YES];
    
}


// Selector method of FacebookLoginButton
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
}


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
        }
    }];
    [connection start];

    
}


//alert method for Use easily
- (void)alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:okAction];
    alert.view.tag = tag;
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

//selector Method of ordinary loginButton
- (void)clickLoginButton:(UIButton *)sender {

    ServerConnection * connection =[[ServerConnection alloc]init];
    [connection authenticateWithUserEmail:self.emailField.text
                         withUserPassword:self.passWordField.text
                               completion:^(BOOL success) {
                                   NSLog(@"구동");
                                   if (success) {
                                       NSLog(@"석세스");
                            
                                       // Set ID & Password in Keychain for AutoLogin
                                       KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
                                       
                                       [keychainItem setObject:_emailField.text forKey:(__bridge id)kSecAttrAccount];
                                       [keychainItem setObject:_passWordField.text forKey:(__bridge id)kSecValueData];
                                       
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                       
                                   } else {
                                       NSLog(@"fa일");

                                       
                                       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSessionNotiNetwork:) name:@"NotierrorforNetwork" object:nil];
                                       
                                       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSessionNotiLogin:) name:@"Notierrorlogin" object:nil];
                                                                        }
                               }];
    
}

- (void) getSessionNotiNetwork:(NSNotification *) notif
{
    [self alertStatus:@"지금은 서버 점검중 입니다. 잠시후에 접속해 주세요.":@"에러" :1];
}

- (void) getSessionNotiLogin:(NSNotification *) notif
{
    
    [self alertStatus:@"로그인이 실패했습니다. 아이디와 비밀번호를 다시 확인해 주세요" :@"에러" :1];
    
}


#pragma mark TextFieldDelegate
// TextField Delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
       
        CGRect newFrame = self.view.frame;
        newFrame.origin.y -=   self.view.frame.size.height/4;
        self.view.frame = newFrame;
        
    }];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect newFrame = self.view.frame;
        newFrame.origin.y += self.view.frame.size.height/4;
        self.view.frame = newFrame;
        
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
   if(textField == self.emailField)
   {
       [textField endEditing:YES];
       [self.passWordField becomeFirstResponder];
   }else{
       [textField endEditing:YES];
       [self clickLoginButton:self.loginButton];
   }
    
    
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end