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

@interface SignUpViewController ()
@property (weak, nonatomic)  UITextField *emailField;
@property (weak, nonatomic)  UITextField *passWordField;
@property (weak, nonatomic)  UITextField *rePasswordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.view setBackgroundColor:[UIColor orangeColor]];
    
    const CGFloat VIEW_MARGIN = 20;
   
    CGSize textFieldSize = CGSizeMake(self.view.frame.size.width - VIEW_MARGIN*6, 40);
    CGSize buttonSize = CGSizeMake(80, 30);
    
    CGFloat offsetY = 100;
    
//   make email, password, repassword Textfield
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

    
    
    UITextField *repasswordTF = [[UITextField alloc]initWithFrame:CGRectMake(VIEW_MARGIN*3,offsetY,textFieldSize.width,textFieldSize.height)];
    [repasswordTF setBorderStyle:UITextBorderStyleRoundedRect];
    [repasswordTF setBackgroundColor:[UIColor whiteColor]];
    [repasswordTF setPlaceholder:@"input Password again"];
    [self.view bringSubviewToFront:repasswordTF];
    self.rePasswordField = repasswordTF;
    [self.view addSubview:repasswordTF];
    offsetY+=repasswordTF.frame.size.height+VIEW_MARGIN;
    
    
    
    [self.passWordField setSecureTextEntry:YES];
    [self.rePasswordField setSecureTextEntry:YES];
    
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passWordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passWordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.rePasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.rePasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    
    
    //make backbutton and registerbutton
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.backgroundColor = [UIColor cyanColor];
    [registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [registerButton setFrame:CGRectMake(VIEW_MARGIN+buttonSize.width*2-10, offsetY, buttonSize.width, buttonSize.height)];
    [registerButton addTarget:self action:@selector(clickRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backbutton10.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(10, 30, 30, 30)];
    [backButton addTarget:self action:@selector(clickBackbutton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
}


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
- (void)clickBackbutton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)clickRegisterButton:(UIButton *)sender {
    
    if([self.emailField.text isEqualToString:@""] ||[self.passWordField.text isEqualToString:@""]||[self.rePasswordField.text isEqualToString:@""]){
        // Error Alert( not filled)
        [self alertStatus:@"not filled" :@"Error" :1];
        
    }else{
        if([self.emailField.text isValidEmail])
        {
        [self checkPasswordMatch];
        }
        else{
            [self alertStatus:@"not valid Email form" :@"Error" :1];
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
        [self alertStatus:@"Doesn't match password":@"Error" :1];
    }
}

//register new user method
-(void)registerNewUser{
    //    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:self.emailField.text forKey:@"userEmail"];
    //    [defaults setObject:self.passWordField.text forKey:@"userPassword"];
    //    [defaults setBool:YES forKey:@"registered"];
    //
    //    [defaults synchronize];
    //    [self alertStatus:@"You've registered a new user" :@"Success" :1];
    
    ServerConnection * connection =[[ServerConnection alloc]init];
    //register User method
    [connection registerWithUserEmail:self.emailField.text withUserPassword:self.passWordField.text];
    
    [self alertStatus:@"You've been registered" :@"Success" :1];
    
   //Action After register user
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end