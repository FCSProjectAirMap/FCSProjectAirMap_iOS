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
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ryan10.png"]];
    [backgroundView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:backgroundView];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
//    emailTextField & passwordTextField Setting
    const CGFloat VIEW_MARGIN = 20*screenWidth/375;
    CGSize textFieldSize = CGSizeMake(self.view.frame.size.width - VIEW_MARGIN*6, 40);
    CGSize buttonSize = CGSizeMake(80*screenWidth/375, 30*screenWidth/375);
    
    CGFloat offsetY = (self.view.frame.size.height/2)+120;
    
    UITextField *emailTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [emailTF setBackgroundColor:[UIColor whiteColor]];
    [emailTF setBorderStyle:UITextBorderStyleRoundedRect];
    [emailTF setPlaceholder:@"이메일을 입력하세요"];
    [self.view bringSubviewToFront:emailTF];
    self.emailField =emailTF;
    [self.view addSubview:emailTF];
    [emailTF setKeyboardType:UIKeyboardTypeEmailAddress];
    offsetY +=emailTF.frame.size.height+VIEW_MARGIN;
    
    UITextField *passwordTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [passwordTF setBorderStyle:UITextBorderStyleRoundedRect];
    [passwordTF setBackgroundColor:[UIColor whiteColor]];
    [passwordTF setPlaceholder:@"패스워드를 입력하세요"];
    [self.view bringSubviewToFront:passwordTF];
    self.passWordField = passwordTF;
    [self.view addSubview:passwordTF];
    offsetY +=passwordTF.frame.size.height+VIEW_MARGIN;
    
    [self.passWordField setSecureTextEntry:YES];
    
    
    self.emailField.delegate = self;
    self.passWordField.delegate = self;
    
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passWordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passWordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    

//  Make buttonView contains buttons (signup,Login,LoginWithFacebook)
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height-offsetY)];
    [buttonView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:buttonView];
    
    
    const CGFloat BUTTONVIEW_MARGIN = 35*screenWidth/375;

    //    signup, Login, LoginwithFacebook Button setting
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor =[UIColor darkGrayColor];
    [loginButton setTitle:@"로그인" forState:UIControlStateNormal];
    [loginButton setFrame:CGRectMake(BUTTONVIEW_MARGIN,0,buttonSize.width,buttonSize.height)];
    [loginButton addTarget:self action:@selector(clickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    loginButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.loginButton = loginButton;
    [buttonView addSubview:loginButton];
    
    
    UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signupButton.backgroundColor = [UIColor greenColor];
    [signupButton setTitle:@"회원가입" forState:UIControlStateNormal];
    [signupButton setFrame:CGRectMake(BUTTONVIEW_MARGIN*2 + buttonSize.width,0, buttonSize.width, buttonSize.height)];
    [signupButton addTarget:self action:@selector(clickSignUpButton:) forControlEvents:UIControlEventTouchUpInside];
    signupButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    signupButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.signupButton = signupButton;
    [buttonView addSubview:signupButton];
    
    
    UIButton *facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    facebookLoginButton.backgroundColor = [UIColor blueColor];
    [facebookLoginButton setTitle:@"페이스북" forState:UIControlStateNormal];
    [facebookLoginButton setFrame:CGRectMake(BUTTONVIEW_MARGIN*3+buttonSize.width*2,0, buttonSize.width, buttonSize.height)];
    [facebookLoginButton addTarget:self action:@selector(facebookLoginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:facebookLoginButton];
    
    facebookLoginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    facebookLoginButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.facebookLoginButton = facebookLoginButton;
    
    

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
                                       
                                       [self alertStatus:@"로그인이 실패했습니다. 아이디와 비밀번호를 다시 확인해 주세요" :@"에러" :1];
                                       
                                       
                                   }
                               }];
    
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