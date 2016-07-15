//
//  PlacesViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 6..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "PlacesViewController.h"


// MapViewContorller에 동일하게 사용하는 이름이 있어서 사용하면 링크 에러뜸...
//const CGFloat BUTTON_SIZE_WIDTH = 34.0f;
//const CGFloat BUTTON_SIZE_HEIGHT = 34.0f;
//const CGFloat X_MARGIN = 10.0f;
//const CGFloat Y_MARGIN = 10.0f;
//const CGFloat TEXTFIELD_HEIGHT = 45.0f;

@interface PlacesViewController ()
<UITextFieldDelegate, GMSAutocompleteTableDataSourceDelegate>

@property (nonatomic, weak) UITextField *searchField;
@property (nonatomic, weak) UIButton *backButton;

@property (nonatomic) UITableViewController *resultTableViewController;
@property (nonatomic) GMSAutocompleteTableDataSource *tableDataSource;

@end

@implementation PlacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    // view 만들어 주기.
    [self createView];
}

- (void)createView {
    
    const CGFloat BUTTON_SIZE_WIDTH = 50.0f;
//    const CGFloat BUTTON_SIZE_HEIGHT = 50.0f;
    const CGFloat X_MARGIN = 10.0f;
    const CGFloat Y_MARGIN = 10.0f;
    const CGFloat TEXTFIELD_HEIGHT = 45.0f;
    
    // 설정 버튼
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(X_MARGIN, Y_MARGIN*2, BUTTON_SIZE_WIDTH, TEXTFIELD_HEIGHT)];
    [backButton addTarget:self
                   action:@selector(backButtonTouchUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
    backButton.backgroundColor = [UIColor whiteColor];
    [backButton setImage:[UIImage imageNamed:@"Back_icon"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    // 구글지도 검색 텍스트 필드
    // ##SJ x좌표를 settingsButton 가로 길이로 했는데 정확하게 되질 않는다....
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(X_MARGIN + backButton.frame.size.width, backButton.frame.origin.y, self.view.frame.size.width - backButton.frame.size.width - (X_MARGIN*2), TEXTFIELD_HEIGHT)];
    [searchField addTarget:self
                    action:@selector(searchFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
    searchField.placeholder = @"검색";
    searchField.borderStyle = UITextBorderStyleNone;
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.returnKeyType = UIReturnKeyDone;
    searchField.keyboardType = UIKeyboardTypeDefault;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:searchField];
    self.searchField = searchField;
    self.searchField.delegate = self;
    [self.searchField becomeFirstResponder];
    
    // GMSAutocomplete Table DataSource
    self.tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    self.tableDataSource.delegate = self;
    
    // Table View Controller
    self.resultTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.resultTableViewController.tableView.delegate = self.tableDataSource;
    self.resultTableViewController.tableView.dataSource = self.tableDataSource;
}


#pragma mark - GMSAutocompleteTableDataSourceDelegate
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
    [self.searchField resignFirstResponder];
    [self.delegate placesInfoShow:place];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didFailAutocompleteWithError:(NSError *)error {
    [self.searchField resignFirstResponder];
    DLog(@"GMSAutocompleteTableDataSource ERROR : %@", error);
    self.searchField.text = @"";
}

- (void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.resultTableViewController.tableView reloadData];
}

- (void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.resultTableViewController.tableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self addChildViewController:self.resultTableViewController];
    self.resultTableViewController.view.frame = CGRectMake(10.0f, self.backButton.bounds.size.height + self.backButton.bounds.origin.y + 50.0f, self.view.bounds.size.width - (10.f * 2), self.view.bounds.size.height - 44.0f);
    self.resultTableViewController.view.alpha = 0.0f;
    [self.view addSubview:self.resultTableViewController.view];
    [self.resultTableViewController.tableView reloadData];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.resultTableViewController.view.alpha = 1.0f;
                     } completion:nil];
    [self.resultTableViewController didMoveToParentViewController:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.resultTableViewController willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.resultTableViewController.view.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.resultTableViewController.view removeFromSuperview];
                         [self.resultTableViewController removeFromParentViewController];
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Action Method
// 뒤로가기 버튼 눌렀을 때 메서드
- (void)backButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

// 지역검색 Field의 텍스트가 변경될 때 마다 실행되는 메서드
- (void)searchFieldDidChange:(UITextField *)textField {
    // 변경된 텍스트를 데이터 소스에 알려준다.
    [self.tableDataSource sourceTextHasChanged:textField.text];
}

@end
