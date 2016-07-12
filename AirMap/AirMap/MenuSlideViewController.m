//
//  MenuSlideViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 8..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MenuSlideViewController.h"

const CGFloat VIEW_HEIGHT = 250.0f;

@interface MenuSlideViewController ()

@property (nonatomic, weak) UIView *userInfoView;
@property (nonatomic, weak) UILabel *applicationNameLabel;
@property (nonatomic, weak) UILabel *userIDLabel;
@property (nonatomic, weak) UITableView *menuTableView;

@end

@implementation MenuSlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)setupUI {
    
    // user Info View
    UIView *userInfoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, VIEW_HEIGHT)];
    userInfoView.backgroundColor = [UIColor colorWithRed:250/225.0f
                                                   green:225.0/225.0f
                                                    blue:0.0/225.0f
                                                   alpha:1.0f];
    [self.view addSubview:userInfoView];
    self.userInfoView = userInfoView;
    
    // application Name Label
    UILabel *applicationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height/2, self.view.frame.size.width, 50.0f)];
    applicationNameLabel.text = @"KaKaoTaxi";
    applicationNameLabel.font = [UIFont systemFontOfSize:10.0f];
    applicationNameLabel.textColor = [UIColor blackColor];
    [self.userInfoView addSubview:applicationNameLabel];
    self.applicationNameLabel = applicationNameLabel;
    
    // user ID Label
    UILabel *userIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, applicationNameLabel.frame.origin.y + applicationNameLabel.frame.size.height + 10.0f, self.view.frame.size.width, 50.0f)];
    userIDLabel.text = @"wngus606@gmila.com";
    userIDLabel.textColor = [UIColor blackColor];
    [self.userInfoView addSubview:userIDLabel];
    self.userIDLabel = userIDLabel;
    
    // menu Table View
    UITableView *menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, userInfoView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - VIEW_HEIGHT) style:UITableViewStylePlain];
    
    [self.view addSubview:menuTableView];
    self.menuTableView = menuTableView;
}

@end
