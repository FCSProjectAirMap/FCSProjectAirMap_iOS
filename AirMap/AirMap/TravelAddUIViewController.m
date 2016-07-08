//
//  TravelAddUIViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 7..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelAddUIViewController.h"

@interface TravelAddUIViewController()

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *topLabel;
@property (nonatomic, weak) UILabel *bottomLabel;
@property (nonatomic, weak) UITableView *detailTableView;
@property (nonatomic, weak) UIImageView *placeholderImageView;

@end

@implementation TravelAddUIViewController

- (void)viewDidLoad {
    NSLog(@"Travel Add viewDidLoad");
    self.title = @"여행 상세 정보";
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(travelAddUIViewCloseTouchUpInside:)]];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self createView];
    
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
}

- (void)createView {
    
    // top View
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, self.view.frame.size.width, 50.0f)];
    [topView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:topView];
    self.topView = topView;
    
    // top Label
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.topView.frame.size.width, self.topView.frame.size.height)];
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.textColor = [UIColor blackColor];
    topLabel.text = self.travelName;
    [self.topView addSubview:topLabel];
    self.topLabel = topLabel;
    
    DLog(@"travelName : %@", self.travelName);
    
    if (self.travelName == nil) {
        
        // placeholder ImageView
        UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, topView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - topView.frame.size.height)];
        UIImage *image = [UIImage imageNamed:@"Ryan"];
        placeholderImageView.image = image;
        placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:placeholderImageView];
        self.placeholderImageView = placeholderImageView;
        
        // bottom View
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 50.0f, self.view.frame.size.width, 50.0f)];
        [bottomView setBackgroundColor:[UIColor yellowColor]];
        [self.view addSubview:bottomView];
        self.bottomView = bottomView;
        
        // bottom Label
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bottomView.frame.size.width, bottomView.frame.size.height)];
        bottomLabel.textColor = [UIColor blackColor];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.text = @"설정된 여행 경로가 없습니다!";
        [self.bottomView addSubview:bottomLabel];
        self.bottomLabel = bottomLabel;
        
    } else {
        // TableView
        // ##SJ 왜 타이틀 뷰 바로 밑에 안붙는지???
        UITableView *detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, topView.frame.size.height + 64.0f, self.view.frame.size.width, self.view.frame.size.height - topView.frame.size.height) style:UITableViewStylePlain];
        [self.view addSubview:detailTableView];
        self.detailTableView = detailTableView;
    }
}

#pragma mark - Action Method
- (void)travelAddUIViewCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewDelegate, TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    return cell;
}

@end
