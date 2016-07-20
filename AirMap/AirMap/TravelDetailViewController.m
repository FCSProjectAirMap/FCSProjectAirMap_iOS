//
//  TravelDetailViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 10..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelDetailViewController.h"

const CGFloat ROW_HEIGHT = 350.0f;

@interface TravelDetailViewController ()

@property (nonatomic, weak) UITableView *detailTableView;
@property (nonatomic, strong) TravelList *travelList;
@property (nonatomic, strong) RLMNotificationToken *notification;
@property (nonatomic, weak) UIImageView *placeholderImageView;

@end

@implementation TravelDetailViewController

- (instancetype)initWithTravelList:(TravelList *)travelList
{
    self = [super init];
    if (self) {
        _travelList = travelList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Travel Detial viewDidLoad");
    [self setupUI];
    
    __weak typeof(self) weakSelf = self;
    self.notification = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        NSLog(@"notification : %@", notification);
        [weakSelf.detailTableView reloadData];
    }];
}

#pragma mark - General Method
- (void)setupUI {
    
    // overLayView 선택할 시.
    if (self.overLayFlag) {
        // Navigation Bar TitleText Color
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:220.0/225.0f green:215.0/225.0f blue:215.0/225.0f alpha:1.0f]}];
        // Navigation Bar Color
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:60.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:1.0f]];
        // Navigation left Button
        UIBarButtonItem *leftBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(travelTableViewCloseTouchUpInside:)];
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:220.0/225.0f green:215.0/225.0f blue:215.0/225.0f alpha:1.0f];
    }
    
    // view
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // TableView
    UITableView *detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [self.view addSubview:detailTableView];
    self.detailTableView = detailTableView;
    self.title = self.travelList.travel_title;
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;

//    if (self.travelName == nil) {
//        
//        // placeholder ImageView
//        UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, topView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - topView.frame.size.height)];
//        UIImage *image = [UIImage imageNamed:@"Ryan"];
//        placeholderImageView.image = image;
//        placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
//        [self.view addSubview:placeholderImageView];
//        self.placeholderImageView = placeholderImageView;
//        
//        // bottom View
//        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 50.0f, self.view.frame.size.width, 50.0f)];
//        [bottomView setBackgroundColor:[UIColor yellowColor]];
//        [self.view addSubview:bottomView];
//        self.bottomView = bottomView;
//        
//        // bottom Label
//        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bottomView.frame.size.width, bottomView.frame.size.height)];
//        bottomLabel.textColor = [UIColor blackColor];
//        bottomLabel.textAlignment = NSTextAlignmentCenter;
//        bottomLabel.text = @"설정된 여행 경로가 없습니다!";
//        [self.bottomView addSubview:bottomLabel];
//        self.bottomLabel = bottomLabel;
//        
//    } else {
//    }
}

#pragma mark - Action Method
- (void)travelTableViewCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewDelegate, TableViewDataSource
// section header height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
// row 높이
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}
// 여행경로의 사진 리스트 수
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DLog(@"image_metadatas count : %ld", self.travelList.image_datas.count);
    return self.travelList.image_datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"detailCell";
    TravelDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[TravelDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Realm에 저장된 메타데이터, 이미지 가져오기
    ImageData *imageMetaData = self.travelList.image_datas[indexPath.row];
    UIImage *image = [[UIImage alloc] initWithData:imageMetaData.image];
    NSDictionary *travelDetailInfoDictionary = @{ @"image": image,
//                                                  @"timezone_date": [NSString stringWithFormat:@"%@", imageMetaData.timezone_date],
//                                                  @"country": imageMetaData.country,
                                                  @"imageHeight":@(ROW_HEIGHT) };
    
    cell.travelDetailInfoDictionary = travelDetailInfoDictionary;
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 0.5f;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
