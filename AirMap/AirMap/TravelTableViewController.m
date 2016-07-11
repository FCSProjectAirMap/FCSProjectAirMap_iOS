//
//  TravelTableViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 7..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//                                                                                                                                                                                  

#import "TravelTableViewController.h"

@interface TravelTableViewController ()

// ##SJ Test
@property (nonatomic) NSMutableArray *dataArray;
@end

@implementation TravelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:1];
}

#pragma mark - Action Method

- (void)travelTableViewCloseTouchUpInside:(UIBarButtonItem *)barButtonItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)travelTableViewAddTouchUpInside:(UIBarButtonItem *)barButtonItem {
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
    
    SCLTextView *travelNameTextField = [alert addTextField:@"제목"];
    [alert addButton:@"저장"
     validationBlock:^BOOL{
         if (travelNameTextField.text.length < 1) {
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
         DLog(@"%@", travelNameTextField.text);
         // response DataCenter insert?
         [self.dataArray addObject:travelNameTextField.text];
         
         // tableview insert
         NSArray *path = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0]];
         [self.tableView insertRowsAtIndexPaths:path withRowAnimation:UITableViewRowAnimationAutomatic];
         
         // tableview reloadData
         [self.tableView reloadData];
     }];
    
    [alert showEdit:self title:@"제목" subTitle:@"여행 경로 제목을 작성해 주세요!" closeButtonTitle:@"취소" duration:0.0f];
}

#pragma mark - TableViewDeleage, TableViewDataSource
// 한 row의 cell 높이
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 기본이 44.0
    return 60;
}

// 한 Section당 row의 개수
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"Cell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.delegate = self;
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.rightButtons = [self createSwipeRightButtons:1];
    return cell;
}

// Cell 선택 되었을 때
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelDetailViewController *travelDetailViewController = [[TravelDetailViewController alloc] init];
    travelDetailViewController.travelName = [self.dataArray objectAtIndex:indexPath.row];
    [travelDetailViewController.dataDetailArray addObjectsFromArray:@[@"도오쿄~", @"가나자와~", @"외키나와", @"아마쿠사~", @"고베", @"구마모토", @"나가노"]];
    [self.navigationController pushViewController:travelDetailViewController animated:YES];
    // 셀 선택 해제
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MGSwipeTableCellDelegate
// Swipe했을 때 실행되는 Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    // Delete
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        // path 가져오기
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        // data delete
        [self.dataArray removeObjectAtIndex:path.row];
        
        for (NSString *strMsg in self.dataArray) {
            DLog(@"남아 있는 trabel title : %@", strMsg);
        }
        
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        return NO;
    }
    
    return YES;
}

#pragma mark - General Method
// Cell 오른쪽에 나오는 버튼들 생성 메서드
- (NSArray *)createSwipeRightButtons:(NSInteger) number {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:number];
    NSArray *titles = @[@"삭제"];
    NSArray *colors = @[[UIColor redColor]];
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

// Cell 왼쪽에 나오는 버튼들 생성 메서드
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
