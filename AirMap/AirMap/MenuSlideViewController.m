//
//  MenuSlideViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 8..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MenuSlideViewController.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"

@interface MenuSlideViewController ()

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIView *rightView;
@property (nonatomic, weak) UILabel *applicationNameLabel;
@property (nonatomic, weak) UILabel *userIDLabel;
@property (nonatomic, weak) UITableView *menuTableView;

@property (nonatomic, strong) NSArray *menuSectionTitle;
@property (nonatomic, strong) NSDictionary *menuDetailDictionary;

@property (nonatomic, strong) NSArray *contents;
@end

@implementation MenuSlideViewController


//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.menuSectionTitle = @[@"설정", @"정보/문의", @"기타"];
//        self.menuDetailDictionary = @{self.menuSectionTitle[0]:@[@"아이디?", @"비번???", @"뭐지??"],
//                                      self.menuSectionTitle[1]:@[@"이벤트 알림 설정", @"서비스 문의", @"친구에게 추천하기", @"현재 버전 1.0"],
//                                      self.menuSectionTitle[2]:@[@"서비스 약관", @"개인정보 취급방침", @"오픈소스 라이센스"]};
//    }
//    return self;
//}



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
    
    // top View
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MENU_VIEW_WIDTH, VIEW_HEIGHT)];
    topView.backgroundColor = [UIColor colorWithRed:250/225.0f green:225.0/225.0f blue:0.0/225.0f alpha:1.0f];
    [self.view addSubview:topView];
    self.topView = topView;
    
    // bottom View
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, topView.frame.size.height, MENU_VIEW_WIDTH, self.view.frame.size.height - VIEW_HEIGHT)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    // application Name Label
    UILabel *applicationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, topView.frame.size.height/2, topView.frame.size.width, 50.0f)];
    applicationNameLabel.text = @"Travel-MK";
    applicationNameLabel.font = [UIFont systemFontOfSize:20.0f];
    applicationNameLabel.textColor = [UIColor blackColor];
    applicationNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:applicationNameLabel];
    self.applicationNameLabel = applicationNameLabel;
    
    // user ID Label
    UILabel *userIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_MARGIN, topView.frame.size.height - 50.0f, topView.frame.size.width - X_MARGIN, 50.0f)];
    userIDLabel.text = self.userID;
    userIDLabel.textColor = [UIColor blackColor];
    userIDLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.topView addSubview:userIDLabel];
    self.userIDLabel = userIDLabel;
    
    // menu Table View
//    UITableView *menuTableView = [[UITableView alloc] initWithFrame: style:UITableViewStylePlain];
////    [self.bottomView addSubview:menuTableView];
//    self.menuTableView = menuTableView;
//    self.menuTableView.delegate = self;
//    self.menuTableView.dataSource = self;
//    
    SKSTableView *sksTableView= [[SKSTableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, MENU_VIEW_WIDTH, bottomView.frame.size.height) style:UITableViewStylePlain];
    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
    sksTableView.SKSTableViewDelegate = self;
    [self.bottomView addSubview: sksTableView];
    self.tableView = sksTableView;
    

    
}

#pragma mark - Action Method
- (void)tapSomeWhereElse:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotiForParentViewTouch" object:self userInfo:nil];
        
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


- (void)collapseSubrows
{
    [self.tableView collapseCurrentlyExpandedIndexPaths];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
// Section Title
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSLog(@"Section Title : %@", [self.menuSectionTitle objectAtIndex:section]);
//    return [self.menuDetailDictionary objectForKey:[self.menuSectionTitle objectAtIndex:section]];
//}




- (NSArray *)contents
{
    if (!_contents)
    {
        _contents = @[
                      @[
                          @[@"설정", @"아이디?",@"비번?",@"뭐지??"],
                          @[@"정보/문의", @"이벤트 알림 설정", @"서비스 문의", @"친구에게 추천하기", @"현재 버전 1.0"],
                          @[@"기타", @"서비스 약관", @"개인정보 취급 방침", @"오픈소스 라이센스", @"기타니까 기타나 치자"]]
                                          ];
    }
    
    return _contents;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.contents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents[section] count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.contents[indexPath.section][indexPath.row] count] - 1;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return YES;
    }
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.contents[indexPath.section][indexPath.row][0];
    cell.selected = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 0 || indexPath.row == 2)))
        cell.expandable = YES;
    else
        cell.expandable = NO;
    
  

    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.contents[indexPath.section][indexPath.row][indexPath.subRow]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    
    return cell;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"didSelectRow Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
    
    
   
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectSubRow Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
}






// Section Height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}
//// Section Count
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"Section Count : %ld", [self.menuSectionTitle count]);
//    return [self.menuSectionTitle count];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"row Count : %ld", [[self.menuDetailDictionary objectForKey:[self.menuSectionTitle objectAtIndex:section]] count]);
//    return [[self.menuDetailDictionary objectForKey:[self.menuSectionTitle objectAtIndex:section]] count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *reuseIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
//    }
//    
//    return cell;
//}

@end
