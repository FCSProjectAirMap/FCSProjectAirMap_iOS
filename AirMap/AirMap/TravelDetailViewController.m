//
//  TravelDetailViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 10..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelDetailViewController.h"

@interface TravelDetailViewController ()

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *topLabel;
@property (nonatomic, weak) UILabel *bottomLabel;
@property (nonatomic, weak) UITableView *detailTableView;
@property (nonatomic, weak) UIImageView *placeholderImageView;

@end

@implementation TravelDetailViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataDetailArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Travel Detial viewDidLoad");
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setupUI];
    self.title = self.travelName;
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
}

#pragma mark - General Method
- (void)setupUI {
    
    // ##SJ Test
    for (NSString *strMsg in self.dataDetailArray) {
        DLog(@"리스트 : %@", strMsg);
    }
    
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

// Cell 오른쪽에 나오는 버튼들 생성 메서드
- (NSArray *)createSwipeRightButtons:(NSInteger) number {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:number];
    NSArray *titles = @[@"삭제",@"수정"];
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

#pragma mark - Action Method
//- (void)travelDetailCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - TableViewDelegate, TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataDetailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"Cell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.delegate = self;
    }
    
    cell.textLabel.text = [self.dataDetailArray objectAtIndex:indexPath.row];
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.rightButtons = [self createSwipeRightButtons:2];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
//    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
//          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    // Modify
    if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        DLog(@"Modify");
    }
    // Delete
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        DLog(@"Delete");
        NSIndexPath *path = [self.detailTableView indexPathForCell:cell];
        [self.dataDetailArray removeObjectAtIndex:path.row];
        [self.detailTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    return YES;
}
@end
