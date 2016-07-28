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
@property (nonatomic, strong) TravelActivation *travelActivation;
@property (nonatomic, weak) UIImageView *placeholderImageView;

@property (nonatomic, strong) TravelTopView *travelTopView;
@property (nonatomic, strong) TravelBottomView *travelBottomView;

@end

@implementation TravelDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Travel Detial viewDidLoad");
    [self setupUI];
    
    self.travelActivation = [TravelActivation defaultInstance];
    
    // 경로 Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(travelDetailViewReload:) name:@"travelDetailViewReload" object:nil];
    
    if ([TravelActivation defaultInstance].travelList != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTitleChange" object:[TravelActivation defaultInstance].travelList.travel_title];
    }
    
}

#pragma mark - General Method
- (void)setupUI {
    
    const CGFloat bottomViewHeight = 54.0f;
    const CGFloat topViewHeight = 74.0f;
    
    // view
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // travel Top View
    self.travelTopView = [[TravelTopView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, topViewHeight)];
    self.travelTopView.delegate = self;
    self.travelTopView.backgroundColor = [UIColor whiteColor];
    self.travelTopView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.travelTopView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.travelTopView.layer.shadowOpacity = 0.5f;
    [self.travelTopView travelImageListButtonIconImage:[UIImage imageNamed:@"MapView_icon"]];
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
    self.title = self.travelActivation.travelList.travel_title;
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
    
    // HeaderView를 Custom HeaderView로 변경.
    self.detailTableView.tableHeaderView = [self tableViewHeader];
}

- (UIView *)tableViewHeader {
    
    const CGFloat HEADER_MARGIN = 10.0f;
    
    // TableHeader View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 100.0f)];
    
    // 여행 시작 날짜 Label
    UILabel *startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(HEADER_MARGIN, HEADER_MARGIN, headerView.frame.size.width/2 - HEADER_MARGIN, headerView.frame.size.height - HEADER_MARGIN * 2)];
    startDateLabel.text = [self travelStartToEndDate:TravelDateFlagStart];
    startDateLabel.numberOfLines = 0;
    startDateLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:startDateLabel];
    
    // 여행 종료 날짜 Label
    UILabel *endDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(startDateLabel.frame.origin.x + startDateLabel.frame.size.width, HEADER_MARGIN, startDateLabel.frame.size.width, startDateLabel.frame.size.height)];
    endDateLabel.text = [self travelStartToEndDate:TravelDateFlagEnd];
    endDateLabel.numberOfLines = 0;
    endDateLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:endDateLabel];
    
    return headerView;
}

// 여행의 시작일과 마지막일을 설정해주는 메서드.
- (NSString *)travelStartToEndDate:(TravelDateFlag)dateFlag{
    NSString *imageCreationDate = @"";

    // 날짜를 시간순으로 정렬
    RLMResults *result = [self.travelActivation.travelList.image_datas sortedResultsUsingProperty:@"timezone_date" ascending:YES];
    ImageData *firstImageData = [result firstObject];
    ImageData *lastImageData = [result lastObject];
    
    if (firstImageData.timezone_date == nil ||
        lastImageData.timezone_date == nil) {
        return @"날짜가 없어요!!";
    }
    
    NSString *firstDate = firstImageData.timezone_date;
    NSString *lastDate = lastImageData.timezone_date;
    NSArray *firstDateArray = [firstDate componentsSeparatedByString:@" "];
    NSArray *lastDateArray = [lastDate componentsSeparatedByString:@" "];
    
    if (dateFlag == TravelDateFlagStart) {
        // 시작 날짜
        imageCreationDate = firstDateArray[0];
    } else if (dateFlag == TravelDateFlagEnd) {
        // 마지막 날짜
        imageCreationDate = lastDateArray[0];
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

#pragma mark - UIControl Event Method
// DetailTableView Close
- (void)travelTableViewCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification
- (void)travelDetailViewReload:(NSNotification *)notification {
    NSLog(@"DetailView Reload");
    [self.detailTableView reloadData];
    self.detailTableView.tableHeaderView = [self tableViewHeader];
}

#pragma mark - TableViewDelegate, TableViewDataSource
// row 높이
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}
// 여행경로의 사진 리스트 수
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.travelActivation.travelList.image_datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"detailCell";
    TravelDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[TravelDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Realm에 저장된 메타데이터, 이미지 가져오기
    // 날짜를 시간순으로 정렬.
    RLMResults *result = [self.travelActivation.travelList.image_datas sortedResultsUsingProperty:@"timezone_date" ascending:YES];
    ImageData *imageMetaData = result[indexPath.row];
    UIImage *image = [[UIImage alloc] initWithData:imageMetaData.image];
    NSString *imageCountry = imageMetaData.country;
    NSDictionary *travelDetailInfoDictionary = @{ @"image": image,
                                                  @"timezone_date": [NSString stringWithFormat:@"%@", imageMetaData.timezone_date],
                                                  @"country": imageCountry,
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
