//
//  MenuSlideViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 8..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MenuSlideViewController.h"

@interface MenuSlideViewController ()

@property (nonatomic, weak) UIView *userInfoView;
@property (nonatomic, weak) UIView *rightView;
@property (nonatomic, weak) UILabel *applicationNameLabel;
@property (nonatomic, weak) UILabel *userIDLabel;
@property (nonatomic, weak) UITableView *menuTableView;

@end

@implementation MenuSlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSomeWhereElse:)];
    [self.rightView addGestureRecognizer:tapGesture];
}

#pragma mark - General Method
- (void)setupUI {
    const CGFloat VIEW_HEIGHT = 250.0f;
    const CGFloat MENU_VIEW_WIDTH = self.view.frame.size.width*0.65;
    const CGFloat X_MARGIN = 10.0f;
    
    // right View
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(MENU_VIEW_WIDTH, 0.0f, MENU_VIEW_WIDTH, self.view.frame.size.height)];
    rightView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:rightView];
    self.rightView = rightView;
    
    // user Info View
    UIView *userInfoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MENU_VIEW_WIDTH, VIEW_HEIGHT)];
    userInfoView.backgroundColor = [UIColor colorWithRed:250/225.0f green:225.0/225.0f blue:0.0/225.0f alpha:1.0f];
    [self.view addSubview:userInfoView];
    self.userInfoView = userInfoView;
    
    // application Name Label
    UILabel *applicationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.userInfoView.frame.size.height/2, self.userInfoView.frame.size.width, 50.0f)];
    applicationNameLabel.text = @"Travel-MK";
    applicationNameLabel.font = [UIFont systemFontOfSize:20.0f];
    applicationNameLabel.textColor = [UIColor blackColor];
    applicationNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.userInfoView addSubview:applicationNameLabel];
    self.applicationNameLabel = applicationNameLabel;
    
    // user ID Label
    UILabel *userIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_MARGIN, self.userInfoView.frame.size.height - 50.0f, self.userInfoView.frame.size.width - X_MARGIN, 50.0f)];
    userIDLabel.text = self.userID;
    userIDLabel.textColor = [UIColor blackColor];
    userIDLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.userInfoView addSubview:userIDLabel];
    self.userIDLabel = userIDLabel;
    
    // menu Table View
    UITableView *menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, userInfoView.frame.size.height, MENU_VIEW_WIDTH, self.view.frame.size.height - VIEW_HEIGHT) style:UITableViewStylePlain];
    [self.view addSubview:menuTableView];
    self.menuTableView = menuTableView;
}

#pragma mark - Action Method
- (void)tapSomeWhereElse:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded){
        
        [UIView animateWithDuration:0.4 animations:^{
            [self.view setFrame:CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }completion:^(BOOL finished)
         {
             if(finished)
             {
                 [self.view removeFromSuperview];
             }
         }];
    }
}

@end
