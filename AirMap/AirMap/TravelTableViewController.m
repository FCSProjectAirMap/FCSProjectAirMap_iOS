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
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) RLMNotificationToken *notification;

@end

@implementation TravelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI View
    [self setupUI];
    
    // realm파일 저장되어 있는 경로.
    NSLog(@"%@", [RLMRealm defaultRealm].configuration.fileURL);
    
    // user_id의 데이터 정보를 검색.
    // 로그인 할 때 키체인에 저장시켜둔 id를 가져와 해당 객체를 찾는다.
    self.resultArray = [UserInfo objectsWhere:@"user_id == %@", @"wngus606@gmail.com"];
    // 이미 로그인 할때 해당 아이디로 Realm데이터에 insert됨으로 조건을 줄 필요는 없지만 일단 적어 둠.
    // result 객체의 수가 0 이상일 경우는 이미 있는 데이터
    if (self.resultArray.count > 0) {
        self.userInfo = self.resultArray[0];
    }
    
    __weak typeof(self) weakSelf = self;
    self.notification = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString * _Nonnull notification, RLMRealm * _Nonnull realm) {
        NSLog(@"notification : %@", notification);
        [weakSelf.travelTableView reloadData];
    }];
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
    NSArray *titles = @[@"삭 제", @"수 정"];
    NSArray *colors = @[[UIColor redColor], [UIColor lightGrayColor]];
    for (NSInteger i = 0; i < number; ++i) {
        MGSwipeButton *button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell *sender) {
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = (i != 0);
            return autoHide;
        }];
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
            NSLog(@"Convenience callback received (left).");
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}

// Delegate Method (해당 셀을 선택 시 선택 된 셀의 title을 MapView에 념겨준다.)
- (void)selectTravelTitle:(NSString *) title {
    [self.delegate selectTravelTitle:title];
}

#pragma mark - Action Method

// 여행 경로 닫기 버튼 이벤트
- (void)travelTableViewCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 여행 경로 추가 버튼 이벤트
// issues : 버튼을 계속 클릭 시 AlertView가 계송 생성 됨. 확인 버튼을 누를 경우 비활성화 시킨 버튼을 활성화 시킬 수 있지만, 취소버튼을 누를경우 방법이....
- (void)travelTableViewAddTouchUpInside:(UIBarButtonItem *)barButtonItem {
    __weak typeof(self) weakSelf = self;
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.horizontalButtons = YES;
    [alert removeTopCircle];
    
    alert.completeButtonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:250.0/255.0f green:225.0/255.0f blue:0.0/255.0f alpha:1.0f];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        return buttonConfig;
    };
    
    alert.buttonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor colorWithRed:250.0/255.0f green:225.0/255.0f blue:0.0/255.0f alpha:1.0f];
        buttonConfig[@"textColor"] = [UIColor blackColor];
        return buttonConfig;
    };
    
    SCLTextView *travelTitleTextField = [alert addTextField:@"제목"];
    [alert addButton:@"저장"
     validationBlock:^BOOL{
         if (travelTitleTextField.text.length < 1) {
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"경고!!!"
                                                                                       message:@"경로 제목을 입력 해주세요!"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                                    DLog(@"오케바리~");
                                                                }];
             [alertController addAction:okAction];
             [self presentViewController:alertController animated:YES completion:nil];
                                                   
             return NO;
         }
         return YES;
     } actionBlock:^{
         DLog(@"여행 경로 생성 : %@", travelTitleTextField.text);
         
         // 여행 경로 생성! Realm에 저장.
         TravelList *travelist = [[TravelList alloc] init];
         travelist.travel_title = travelTitleTextField.text;
         travelist.activity = NO;
         
         // ##SJ Test Method
         for (NSInteger i = 0; i < 10; ++i) {
             [travelist.image_metadatas addObject:[self testMethod:travelTitleTextField.text index:i]];
         }
         
         DLog(@"Travel List Count : %ld", weakSelf.userInfo.travel_list.count);
         
         // Realm 데이터를 추가 및 업데이트 할경우 Transaction 안에서 적용 해야 한다.
         
         [[RLMRealm defaultRealm] transactionWithBlock:^{
             [weakSelf.userInfo.travel_list addObject:travelist];
         }];
     }];
    
    [alert showEdit:self title:@"제목" subTitle:@"여행 경로 제목을 작성해 주세요!" closeButtonTitle:@"취소" duration:0.0f];
}

// ##SJ Test
- (ImageMetaData *)testMethod:(NSString *)travelTitle index:(NSInteger)index {
    
    ImageMetaData *imageMetaDatas = [[ImageMetaData alloc] init];
    imageMetaDatas.creation_date = [NSDate date];
    imageMetaDatas.latitude = 13.3f;
    imageMetaDatas.longitude = 34.99923f;
    imageMetaDatas.timestamp = 23234.234f;
    imageMetaDatas.timezone_date = [NSDate date];
    imageMetaDatas.country = [NSString stringWithFormat:@"%@_%ld", travelTitle, index];
    return imageMetaDatas;
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
    return self.userInfo.travel_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"Cell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.delegate = self;
    }
    
    TravelList *travelList = [self.userInfo.travel_list objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:25.0f];
    cell.textLabel.text = travelList.travel_title;
    
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.rightButtons = [self createSwipeRightButtons:2];
    return cell;
}

// Cell 선택 되었을 때
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 선택된 셀
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // mapview로 타이틀 정보를 넘겨 줌.
    [self selectTravelTitle:cell.textLabel.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    // 셀 선택 해제
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        TravelList *travelList = [self.userInfo.travel_list objectAtIndex:path.row];
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            [[RLMRealm defaultRealm] deleteObject:travelList];
            [weakSelf.travelTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        }];
        
        return NO;
    } // modify
    else if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        DLog(@"modify Touch");
        
        TravelList *travelList = [self.userInfo.travel_list objectAtIndex:path.row];
        // TravelDetail View Controller 호출
        TravelDetailViewController *travelDetailViewController = [[TravelDetailViewController alloc] initWithTravelList:travelList];
        [self.navigationController pushViewController:travelDetailViewController animated:YES];
    }
    
    return YES;
}

@end
