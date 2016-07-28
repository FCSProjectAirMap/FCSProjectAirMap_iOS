//
//  TravelTableViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 7..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//                                                                                                                                                                                  

#import "TravelTableViewController.h"

@interface TravelTableViewController ()

@property (nonatomic, weak) UITableView *travelTableView;
@property (nonatomic, strong) RLMResults *resultArray;
@property (nonatomic, strong) UserInfo *travelUserInfo;
@property (nonatomic, strong) RLMNotificationToken *notification;
@property (nonatomic, strong) TravelActivation *travelActivation;

@end

@implementation TravelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 활성화 여행을 참조하고 있는 싱글톤 객체.
    self.travelActivation = [TravelActivation defaultInstance];
    
    // UI View
    [self setupUI];
    
    // realm파일 저장되어 있는 경로.
    NSLog(@"%@", [RLMRealm defaultRealm].configuration.fileURL);
    
    // set ID (from keychain)
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    NSString *keyChainUser_id = [keychainItem objectForKey: (__bridge id)kSecAttrAccount];
    
    // user_id의 데이터 정보를 검색.
    // 로그인 할 때 키체인에 저장시켜둔 id를 가져와 해당 객체를 찾는다.
    self.resultArray = [UserInfo objectsWhere:@"user_id == %@", keyChainUser_id];
    // 이미 로그인 할때 해당 아이디로 Realm데이터에 insert됨으로 조건을 줄 필요는 없지만 일단 적어 둠.
    // result 객체의 수가 0 이상일 경우는 이미 있는 데이터
    if (self.resultArray.count > 0) {
        self.travelUserInfo = self.resultArray[0];
    }
    
    __weak typeof(self) weakSelf = self;
    self.notification = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        NSLog(@"notification : %@", notification);
        [weakSelf.travelTableView reloadData];
    }];
    
    // 하단 +를 눌렀을 경우 호출 되는 NotificationCenter등록.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(travelListMake:) name:@"travelListMake" object:nil];
}

#pragma mark - General Method
- (void)setupUI {
    // navigation bar
    self.title = @"여행 경로";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:220.0/225.0f green:215.0/225.0f blue:215.0/225.0f alpha:1.0f]}];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:60.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:1.0f]];
    
    UIBarButtonItem *leftBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(travelTableViewCloseTouchUpInside:)];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                        target:self
                                                                                        action:@selector(travelTableViewAddTouchUpInside:)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:220.0/225.0f green:215.0/225.0f blue:215.0/225.0f alpha:1.0f];
    
    // table View
    UITableView *travelTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [self.view addSubview:travelTableView];
    self.travelTableView = travelTableView;
    self.travelTableView.delegate = self;
    self.travelTableView.dataSource = self;
}

// Swipe Cell 오른쪽에 나오는 버튼들 생성 메서드
- (NSArray *)createSwipeRightButtons:(NSInteger) number {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:number];
    NSArray *titles = @[@"삭제", @"수정"];
    NSArray *colors = @[[UIColor redColor], [UIColor lightGrayColor]];
    for (NSInteger i = 0; i < number; ++i) {
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell *sender) {
            DLog(@"Convenience callback received (right).");
            BOOL autoHide = (i != 0);
            return autoHide;
        }];
        // Button width 설정.
        button.buttonWidth = 80.0f;
        [result addObject:button];
    }
    return result;
}

// Swipe Cell 왼쪽에 나오는 버튼들 생성 메서드
- (NSArray *)createSwipeLeftButton:(NSInteger) number {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:number];
    NSArray *colors = @[[UIColor colorWithRed:0.59 green:0.29 blue:0.08 alpha:1.0]];
    NSArray *icons = @[[UIImage imageNamed:@""]];
    for (NSInteger i = 0; i < number; ++i) {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:icons[i] backgroundColor:colors[i] padding:15 callback:^BOOL(MGSwipeTableCell * sender){
            DLog(@"Convenience callback received (left).");
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}

// 여행 타이틀 추가 AlertView 호출.
- (void)showTravelListAddAlert {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    // alert font customize
    NSString *message = @"여행 제목을 입력해 주세요~!";
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:message];
    [title addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                           NSFontAttributeName:[UIFont fontWithName:@"NanumGothicOTF" size:13.0]}
                   range:NSMakeRange(0, message.length )];
    [alert setValue:title forKey:@"attributedTitle"];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"확 인"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         NSString *travelTitle = alert.textFields.firstObject.text;
                                                         if (travelTitle.length == 0 || [travelTitle containsString:@""]) {
                                                             [self showTravelListAddAlert];
                                                         } else {
                                                             // 여행 경로생성~ Realm에 저장.
                                                             TravelList *travelList = [[TravelList alloc] init];
                                                             travelList.travel_title = travelTitle;
                                                             // 유니크한 값을 주기 위해 생성된 시간을 title뒤에 붙여준다. milliseconds로 계산.
                                                             NSInteger creation_titleTitle = [[NSDate date] timeIntervalSince1970] * 1000;
                                                             NSString *travelTitleTimeStamp = [NSString stringWithFormat:@"%@_%ld", travelTitle, creation_titleTitle];
                                                             DLog(@"travelTitleTimeStamp : %@", travelTitleTimeStamp);
                                                             DLog(@"createion_titleTitle : %ld", creation_titleTitle);
                                                             // ##SJ DetailTableCell 정렬을 위해 생성일을 넣어준다.
                                                             travelList.creation_travelTitle = creation_titleTitle;
                                                             travelList.travel_title_unique = travelTitleTimeStamp;
                                                             travelList.activity = NO;
                                                             
                                                             // Realm 데이터를 추가 및 업데이트 할 경우 Transaction 안에서 적용 해야 한다.
                                                             RLMRealm *realm = [RLMRealm defaultRealm];
                                                             [realm beginWriteTransaction];
                                                             [weakSelf.travelUserInfo.travel_list addObject:travelList];
                                                             [realm commitWriteTransaction];
                                                            
                                                             // ##MJ 서버에 새로생긴 travleTitle 저장 후 id_number값을 받아온다.
                                                             [[RequestObject sharedInstance] uploadTravelTitleDatas:travelTitle
                                                                                                       inTravelList:travelList];
                                                         }
                                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취 소"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        [textField setPlaceholder:@"여행 제목을 입력해 주세요!"];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

// TravelList를 소팅해주는 메서드.
- (RLMResults *)travelListsortedResultsUsingProperty:(NSString *)property ascending:(BOOL)ascending {
    return [self.travelUserInfo.travel_list sortedResultsUsingProperty:property ascending:ascending];
}

- (NSString *)firstDateAndLastDateInTravelList:(TravelList *)travelList {
    RLMResults *result = [travelList.image_datas sortedResultsUsingProperty:@"timezone_date" ascending:YES];
    ImageData *firstImageData = [result firstObject];
    ImageData *lastImageData = [result lastObject];
    
    NSLog(@"firstImageData : %@", firstImageData.timezone_date);
    NSLog(@"lastImageData : %@", lastImageData.timezone_date);
    if (firstImageData.timezone_date == nil ||
        lastImageData.timezone_date == nil) {
        return @"지도위에 당산의 발자취를 남겨주세요!";
    }
    
    NSString *firstDate = firstImageData.timezone_date;
    NSString *lastDate = lastImageData.timezone_date;
    NSArray *firstDateArray = [firstDate componentsSeparatedByString:@" "];
    NSArray *lastDateArray = [lastDate componentsSeparatedByString:@" "];
    return [NSString stringWithFormat:@"%@ ~ %@", firstDateArray[0], lastDateArray[0]];
}

#pragma mark - UIControl Event Method
// 여행 경로 닫기 버튼 이벤트
- (void)travelTableViewCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 여행 경로 추가 버튼 이벤트
- (void)travelTableViewAddTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self showTravelListAddAlert];
}

#pragma mark - TableViewDeleage, TableViewDataSource
// 한 row의 cell 높이
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 기본이 44.0
    return 70.0f;
}

// tableview header Height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
// 한 Section당 row의 개수
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.travelUserInfo.travel_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"Cell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.delegate = self;
    }
    // ##SJ 최신생성한 기준으로 정렬.
    RLMResults *sortedResult = [self travelListsortedResultsUsingProperty:@"creation_travelTitle" ascending:NO];
    TravelList *travelList = [sortedResult objectAtIndex:indexPath.row];
    NSInteger imageCount = travelList.image_datas.count;
    
    cell.textLabel.font = [UIFont fontWithName:@"NanumGothicOTF" size:25.0f];
    // 제목 (이미지 수)
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", travelList.travel_title, imageCount];
    // Detail Text
    cell.detailTextLabel.text = [self firstDateAndLastDateInTravelList:travelList];
    // accessory View
    if (imageCount > 0) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_accessory"]];
        cell.accessoryView.frame = CGRectMake(0.0f, 0.0f, 24.0f, 24.0f);
    } else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_accessory"]];
        cell.accessoryView.frame = CGRectMake(0.0f, 0.0f, 24.0f, 24.0f);
    }
    
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.rightButtons = [self createSwipeRightButtons:2];
    return cell;
}

// Cell 선택 되었을 때
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 선택된 여행을 활성화 시켜준다.
    RLMResults *sortedResult = [self travelListsortedResultsUsingProperty:@"creation_travelTitle" ascending:NO];
    TravelList *travelList = [sortedResult objectAtIndex:indexPath.row];
    [self.travelActivation travelListActivation:travelList];
    
    // Title Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTitleChange" object:travelList.travel_title];
    
    // Modal을 MapViewController (rootViewController)에서 호출해야 하기 때문에 rootView의 instance를 참조 해서 앨범 뷰를 호출한다.
    __weak typeof(UIViewController *) weakSelf = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        // 셀 선택 해제
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // 셀이 선택되고 해당 여행 경로의 이미지를 전송 해야 하기 때문에 앨범 뷰를 띄어준다.
        // 선택된 여행 경로에 Travel_List 데이터가 있을 경우에는 앨범뷰를 호출하지 않고 새로 추가된 경우에만 호출
        if (travelList.image_datas.count < 1) {
            [AuthorizationControll moveToMultiImageSelectFrom:weakSelf];
        } else {
            // 선택한 Cell의 경로를 그려주는 Notification을 호출한다.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTrackingDraw" object:nil];
        }
    }];
}

#pragma mark - Noification
- (void)travelListMake:(NSNotificationCenter *)notification {
    [self showTravelListAddAlert];
}

#pragma mark - MGSwipeTableCellDelegate
// Swipe했을 때 실행되는 Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    // path 가져오기
    NSIndexPath *path = [self.travelTableView indexPathForCell:cell];
    
    // Delete
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        DLog(@"Delete Touch");
        
        // Realm Data delete
        __weak typeof(self) weakSelf = self;
        // ##SJ 삭제시 정렬된 순서를 가져와 해당 row를 참조하여 삭제.
        RLMResults *sortedResult = [self travelListsortedResultsUsingProperty:@"creation_travelTitle" ascending:NO];
        TravelList *travelList = [sortedResult objectAtIndex:path.row];

        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            // 이미지 데이터를 지워주고.
            for (ImageData *imageData in travelList.image_datas) {
                [realm deleteObject:imageData];
            }
            // 삭제 시 현재 활성화된 싱글턴 객체와 삭제하려던 여행경로 객체가 같을 경우 처리하는 로직.
            if ([travelList isEqualToObject:weakSelf.travelActivation.travelList]) {
                // 싱글턴이 참조하는 객체를 nil로 만들어 준다.
                weakSelf.travelActivation.travelList = nil;
                // title Notification을 호출해 빈값을 준다.
                [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTitleChange" object:nil];
                // Polyline, Marker Clear
                [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTrackingClear" object:nil];
            }
            
            // 여행 리스트를 지워준다.
            [realm deleteObject:travelList];
            [weakSelf.travelTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        }];
        
        return NO;
    } // modify
    else if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        DLog(@"modify Touch");
        
        // ##SJ 수정할때 정렬된 순서를 가져와서 해당 row를 참조하여 수정.
//        RLMResults *sortedResult = [self travelListsortedResultsUsingProperty:@"creation_travelTitle" ascending:NO];
//        TravelList *travelList = [sortedResult objectAtIndex:path.row];
//        // TravelDetail View Controller 호출
//        TravelDetailViewController *travelDetailViewController = [[TravelDetailViewController alloc] initWithTravelList:travelList];
//        [self.navigationController pushViewController:travelDetailViewController animated:YES];
    }
    
    return YES;
}

@end
