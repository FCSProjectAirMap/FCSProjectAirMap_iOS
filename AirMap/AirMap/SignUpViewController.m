//
//  SignUpViewController.m
//  ProjectLoginRenewal
//
//  Created by Tedigom on 2016. 7. 4..
//  Copyright © 2016년 Tedigom. All rights reserved.
//

#import "SignUpViewController.h"
#import "ServerConnection.h"
#import "MapViewController.h"
#import "NSString+NSString___emailValidation.h"

@interface SignUpViewController ()<UITextFieldDelegate>
@property (weak, nonatomic)  UITextField *emailField;
@property (weak, nonatomic)  UITextField *passWordField;
@property (weak, nonatomic)  UITextField *rePasswordField;


@property (weak,nonatomic)  UIButton *registerButton;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:225/255.0 blue:0/255.0 alpha:1.0f]];
    

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    const CGFloat VIEW_MARGIN = 20*screenWidth/375;
   
    CGSize textFieldSize = CGSizeMake(self.view.frame.size.width - VIEW_MARGIN*6, 40);
    CGSize buttonSize = CGSizeMake(self.view.frame.size.width - VIEW_MARGIN*6,self.view.frame.size.width/7 - VIEW_MARGIN*6/7 );
    
    CGFloat offsetY = self.view.frame.size.height/2-150*screenWidth/375;
    CGFloat fontSize = 30;
    
//   make email, password, repassword Textfield
    UITextField *emailTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [emailTF setBackgroundColor:[UIColor clearColor]];
    [emailTF setBorderStyle:UITextBorderStyleNone];
    [emailTF setPlaceholder:@"Email"];
    [emailTF setFont:[UIFont fontWithName:@"NanumGothic.otf" size:fontSize]];
    [self.view bringSubviewToFront:emailTF];
    self.emailField =emailTF;
    [self.view addSubview:emailTF];
    offsetY +=emailTF.frame.size.height;
    [emailTF setKeyboardType:UIKeyboardTypeEmailAddress];
    
    //line under email textField
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_MARGIN*3, offsetY-7*screenWidth/375, self.emailField.frame.size.width, 2)];
    lineView.backgroundColor = [UIColor colorWithRed:60/255.0 green:30/255.0 blue:30/255.0 alpha:0.6f];
    [self.view addSubview:lineView];
    offsetY +=5;
    

    
    
    
    UITextField *passwordTF =[[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [passwordTF setBorderStyle:UITextBorderStyleNone];
    [passwordTF setBackgroundColor:[UIColor clearColor]];
    [passwordTF setPlaceholder:@"Password"];
    [passwordTF setFont:[UIFont fontWithName:@"NanumGothic.otf" size:fontSize]];
    [self.view bringSubviewToFront:passwordTF];
    self.passWordField = passwordTF;
    [self.view addSubview:passwordTF];
    offsetY +=passwordTF.frame.size.height;
    
    
        //line under password textField
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_MARGIN*3, offsetY-7*screenWidth/375, self.emailField.frame.size.width, 2)];
    lineView2.backgroundColor = [UIColor colorWithRed:60/255.0 green:30/255.0 blue:30/255.0 alpha:0.6f];
    [self.view addSubview:lineView2];
    offsetY +=5;
    

    
    
    UITextField *repasswordTF = [[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [repasswordTF setBorderStyle:UITextBorderStyleNone];
    [repasswordTF setBackgroundColor:[UIColor clearColor]];
    [repasswordTF setPlaceholder:@"Password again"];
    [repasswordTF setFont:[UIFont fontWithName:@"NanumGothic.otf" size:fontSize]];
    [self.view bringSubviewToFront:repasswordTF];
    self.rePasswordField = repasswordTF;
    [self.view addSubview:repasswordTF];
    offsetY+=repasswordTF.frame.size.height;
    
    //line under repassword textField
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_MARGIN*3, offsetY-7*screenWidth/375, self.emailField.frame.size.width, 2)];
    lineView3.backgroundColor = [UIColor colorWithRed:60/255.0 green:30/255.0 blue:30/255.0 alpha:0.6f];
    [self.view addSubview:lineView3];
    offsetY +=VIEW_MARGIN*3;
    
    
    
    [self.passWordField setSecureTextEntry:YES];
    [self.rePasswordField setSecureTextEntry:YES];
    
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passWordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passWordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.rePasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.rePasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.emailField.delegate =self;
    self.passWordField.delegate = self;
    self.rePasswordField.delegate = self;
    
    
    //make backbutton and registerbutton
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton setBackgroundImage:[UIImage imageNamed:@"SignupIcon.png"] forState:UIControlStateNormal];
    [registerButton setFrame:CGRectMake(VIEW_MARGIN*3, offsetY, buttonSize.width, buttonSize.height)];
    [registerButton addTarget:self action:@selector(clickRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    self.registerButton = registerButton;
    [self.view addSubview:registerButton];
    
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backbutton10.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(10, 30, 30, 30)];
    [backButton addTarget:self action:@selector(clickBackbutton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
}



//email validation
-(BOOL)isValidEmail
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark actionMethod
- (void)clickBackbutton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)clickRegisterButton:(UIButton *)sender {
    
    if([self.emailField.text isEqualToString:@""] ||[self.passWordField.text isEqualToString:@""]||[self.rePasswordField.text isEqualToString:@""]){
        // Error Alert( not filled)
        [self alertStatus:@"모든 칸을 채워주세요" :@"에러" :1];
        
    }else{
        if([self.emailField.text isValidEmail])
        {
        [self checkPasswordMatch];
        }
        else{
            [self alertStatus:@"올바른 이메일 형식이 아닙니다." :@"에러" :1];
        }
        
        
    }
    
    
    
}

-(void)checkPasswordMatch {
    if([self.passWordField.text isEqualToString:self.rePasswordField.text])
    {
        NSLog(@"Match PassWord");
        [self registerNewUser];
    }else{
        NSLog(@"Doesn't match password");
        [self alertStatus:@"패스워드가 일치하지 않습니다.":@"에러" :1];
    }
}

//register new user method
-(void)registerNewUser{
    ServerConnection * connection =[[ServerConnection alloc]init];
    //register User method
                 [connection registerWithUserEmail:self.emailField.text withUserPassword:self.passWordField.text completion:^(BOOL success) {
        NSLog(@"register operation");
        if (success) {
            NSLog(@"register newUser Success");
//             [self alertStatus:@"회원가입이 완료되었습니다." :@"성공" :1];
            
//            // Set ID & Password in Keychain for AutoLogin
//            KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
//            
//            [keychainItem setObject:_emailField.text forKey:(__bridge id)kSecAttrAccount];
//            [keychainItem setObject:_passWordField.text forKey:(__bridge id)kSecValueData];
            [self dismissViewControllerAnimated:YES completion:nil];
            
    // check the coincidence of ID and the operation of failure to Register
        } else {
            
            NSLog(@"register fail of error");
            
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSessionNotiError500:) name:@"Notierrorcontains500" object:nil];
            
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSessionNotiErrorAnother:) name:@"NotierrorfortheotherThing" object:nil];
            
        }
    }];

    
//
    

}

- (void) getSessionNotiError500:(NSNotification *) notif
{
    [self alertStatus:@"아이디가 중복되었습니다. 다른 아이디를 입력해 주세요":@"에러" :1];
}

- (void) getSessionNotiErrorAnother:(NSNotification *) notif
{
    [self alertStatus:@"네트워크 연결을 다시한번 확인해 주세요.":@"에러" :1];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.emailField)
    {
        [textField endEditing:YES];
        [self.passWordField becomeFirstResponder];
    }else if(textField == self.passWordField)
    {
        [textField endEditing:YES];
        [self.rePasswordField becomeFirstResponder];
    }
    else{
        [textField endEditing:YES];
        [self clickRegisterButton:self.registerButton];
    }
    
    return YES;
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end