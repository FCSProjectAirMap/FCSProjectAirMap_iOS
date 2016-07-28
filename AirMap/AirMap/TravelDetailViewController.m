//
//  TravelDetailViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 10..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelDetailViewController.h"

// 여행 시작 날짜와 여행 끝나는 날짜의 Enum
typedef NS_ENUM(NSInteger, TravelDateFlag) {
    TravelDateFlagStart = 0,
    TravelDateFlagEnd = 1
};

const CGFloat ROW_HEIGHT = 350.0f;

@interface TravelDetailViewController ()

@property (nonatomic, weak) UITableView *detailTableView;
@property (nonatomic, strong) TravelList *travelList;
@property (nonatomic, weak) UIImageView *placeholderImageView;

@property (nonatomic, strong) TravelTopView *travelTopView;
@property (nonatomic, strong) TravelBottomView *travelBottomView;

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
    
    if ([TravelActivation defaultInstance].travelList != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTitleChange" object:[TravelActivation defaultInstance].travelList.travel_title];
    }
    
}

#pragma mark - General Method
- (void)setupUI {
    
    const CGFloat HEADER_MARGIN = 10.0f;
    const CGFloat bottomViewHeight = 54.0f;
    const CGFloat topViewHeight = 74.0f;

    // ##SJ Test
    // 필요 없을 수도...
//    // overLayView 선택할 시.
//    if (self.overLayFlag) {
//        // Navigation Bar TitleText Color
//        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:220.0/225.0f green:215.0/225.0f blue:215.0/225.0f alpha:1.0f]}];
//        // Navigation Bar Color
//        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:60.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:1.0f]];
//        // Navigation left Button
//        UIBarButtonItem *leftBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                                                          target:self
//                                                                                          action:@selector(travelTableViewCloseTouchUpInside:)];
//        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:220.0/225.0f green:215.0/225.0f blue:215.0/225.0f alpha:1.0f];
//    }
    
    // view
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // travel Top View
    self.travelTopView = [[TravelTopView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, topViewHeight)];
    self.travelTopView.delegate = self;
    self.travelTopView.backgroundColor = [UIColor whiteColor];
    self.travelTopView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.travelTopView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.travelTopView.layer.shadowOpacity = 0.5f;
    [self.view addSubview:self.travelTopView];
    
    // travel Bottom View
    self.travelBottomView = [[TravelBottomView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    self.travelBottomView.delegate = self;
    self.travelBottomView.backgroundColor = [UIColor whiteColor];
    self.travelBottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.travelBottomView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.travelBottomView.layer.shadowOpacity = 0.5f;
    [self.view addSubview:self.travelBottomView];
    
    // TableView
    UITableView *detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, topViewHeight, self.view.frame.size.width, self.view.frame.size.height - bottomViewHeight - topViewHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:detailTableView];
    self.detailTableView = detailTableView;
    self.title = self.travelList.travel_title;
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
    
    // TableHeader View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 100.0f)];
    
    // 여행 시작 날짜 Label
    UILabel *startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(HEADER_MARGIN, HEADER_MARGIN, headerView.frame.size.width/2 - HEADER_MARGIN, headerView.frame.size.height - HEADER_MARGIN * 2)];
    startDateLabel.text = [self travelStartToEndDate:TravelDateFlagStart];
    startDateLabel.numberOfLines = 0;
    startDateLabel.backgroundColor = [UIColor yellowColor];
    startDateLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:startDateLabel];
    
    // 여행 종료 날짜 Label
    UILabel *endDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(startDateLabel.frame.origin.x + startDateLabel.frame.size.width, HEADER_MARGIN, startDateLabel.frame.size.width, startDateLabel.frame.size.height)];
    endDateLabel.text = [self travelStartToEndDate:TravelDateFlagEnd];
    endDateLabel.numberOfLines = 0;
    endDateLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:endDateLabel];
    
    // HeaderView를 Custom HeaderView로 변경.
    self.detailTableView.tableHeaderView = headerView;
}

// 여행의 시작일과 마지막일을 설정해주는 메서드.
- (NSString *)travelStartToEndDate:(TravelDateFlag)dateFlag{
    NSString *imageCreationDate = @"";
    // 날짜를 시간순으로 정렬
    RLMResults *result = [self.travelList.image_datas sortedResultsUsingProperty:@"timezone_date" ascending:YES];
    if (dateFlag == TravelDateFlagStart) {
        // 시작 날짜
        ImageData *imageData = [result firstObject];
        imageCreationDate = imageData.timezone_date;
    } else if (dateFlag == TravelDateFlagEnd) {
        // 마지막 날짜
        ImageData *imageData = [result lastObject];
        imageCreationDate = imageData.timezone_date;
    }
    return imageCreationDate;
}

#pragma mark - Travel Top View Delegate
- (void)didSelectMenuSlideButton:(UIButton *) sender {
    DLog(@"menu Slide");
}
- (void)didSelectTravelTitleButton:(UIButton *) sender {
    DLog(@"travelTitle");
}
- (void)didSelectPlaceSearchButton:(UIButton *) sender {
    DLog(@"PlaceSearch");
}
- (void)didSelectTravelImageListButton:(UIButton *) sender {
    DLog(@"travelImageList");
    UIViewController *rootViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    [[[UIApplication sharedApplication] delegate] window].rootViewController = [rootViewControllerObject defaultInstance].rootViewController;
    [rootViewControllerObject defaultInstance].rootViewController = rootViewController;
}

#pragma mark - Travel Bottom View Delegate
- (void)didSelectTravelPreviousButton:(UIButton *) sender {
    DLog(@"travelPrevious");
}
- (void)didSelectTravelNextButton:(UIButton *) sender {
    DLog(@"travelNext");
}
- (void)didSelectTravelMakeButton:(UIButton *) sender {
    DLog(@"travelMake");
}
- (void)didSelectTravelAlbumButton:(UIButton *) sender {
    DLog(@"travelAlbum");
}

#pragma mark - Action Method
// DetailTableView Close
- (void)travelTableViewCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewDelegate, TableViewDataSource
// row 높이
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}
// 여행경로의 사진 리스트 수
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.travelList.image_datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"detailCell";
    TravelDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[TravelDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Realm에 저장된 메타데이터, 이미지 가져오기
    // 날짜를 시간순으로 정렬.
    RLMResults *result = [self.travelList.image_datas sortedResultsUsingProperty:@"timezone_date" ascending:YES];
    ImageData *imageMetaData = result[indexPath.row];
    UIImage *image = [[UIImage alloc] initWithData:imageMetaData.image];
    NSDictionary *travelDetailInfoDictionary = @{ @"image": image,
                                                  @"timezone_date": [NSString stringWithFormat:@"%@", imageMetaData.timezone_date],
                                                  @"country": @"한국",
                                                  @"imageHeight":@(ROW_HEIGHT) };
    
    cell.travelDetailInfoDictionary = travelDetailInfoDictionary;
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 0.5f;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelDetailImageScrollViewController *imageScrollViewController = [[TravelDetailImageScrollViewController alloc] initWithImageIndex:indexPath.row];
    [self presentViewController:imageScrollViewController animated:YES completion:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

@end
