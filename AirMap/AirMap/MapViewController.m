//
//  MapViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 5..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MapViewController.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>
#import "ViewController.h"

static const CGFloat overlayrHeight = 45.0f;

@interface MapViewController ()

@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) GMSMutablePath *path;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, weak) UIButton *plusButton;
@property (nonatomic, weak) UIButton *albumButton;
@property (nonatomic, weak) UIButton *locationAddButton;
@property (nonatomic, weak) UIButton *travelButton;
@property (nonatomic, weak) UIButton *locationButton;
@property (nonatomic, weak) UIView *plusView;
@property (nonatomic, weak) UIView *overlayView;
@property (nonatomic, weak) UIButton *overlayButton;

@property (nonatomic, weak) UITextField *searchField;
@property (nonatomic, weak) UIButton *menuButton;

@property (nonatomic, weak) UIButton *logoutButton;

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isStatusBarHidden;

@end

@implementation MapViewController

#pragma mark - View LifeCycel
- (void)viewDidLoad {
    [super viewDidLoad];
    // 구글 지도 만들어 주기.
    [self createGoogleMapView];
    
    // view 만들어 주기.
    [self setupUI];
    
    self.path = [GMSMutablePath path];
    self.isAnimating = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSession:) name:@"NotiForParentViewTouch" object:nil];
}


- (void) getSession:(NSNotification *) notif
{
    self.isSlideMenuOpen = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [MapViewController removeGMSBlockingGestureRecognizerFromMapView:self.mapView];
}

//////////////////////////////////// ##SJ Places Test
- (void)placesInfoShow:(GMSPlace *)place {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[place description]];
    if (place.attributions) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        [text appendAttributedString:place.attributions];
    }
    DLog(@"place : %@", text);
    
    // 카메라 위치를 선택한 장소로 이동.
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude
                                                            longitude:place.coordinate.longitude
                                                                 zoom:16.0f];
    [self.mapView setCamera:cameraPosition];
}

#pragma mark - General Method
/****************************************************************************
 *                                                                          *
 *                          General Method                                  *
 *                                                                          *
 ****************************************************************************/
// 구글 지도 위에 올려진 텍스트 필드는 탭 이벤트가 발생하지 않아 막혀있는걸 없에 준다.
+ (void)removeGMSBlockingGestureRecognizerFromMapView:(GMSMapView *)mapView
{
    if([mapView.settings respondsToSelector:@selector(consumesGesturesInView)]) {
        mapView.settings.consumesGesturesInView = NO;
    }
    else {
        for (id gestureRecognizer in mapView.gestureRecognizers)
        {
            if (![gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            {
                [mapView removeGestureRecognizer:gestureRecognizer];
            }
        }
    }
}

// UI 생성 메서드.
- (void)setupUI {
    
    const CGFloat BUTTON_SIZE_WIDTH = 50.0f;
    const CGFloat BUTTON_SIZE_HEIGHT = 50.0f;
    const CGFloat X_MARGIN = 10.0f;
    const CGFloat Y_MARGIN = 10.0f;
    const CGFloat TEXTFIELD_HEIGHT = 45.0f;
    
    // overlay View
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.mapView.frame.size.height - overlayrHeight, self.mapView.frame.size.width, overlayrHeight)];
    overlayView.backgroundColor = [UIColor colorWithRed:60.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:0.9f];
    [self.mapView addSubview:overlayView];
    self.overlayView = overlayView;
    
    // overlayTravelTitle Button
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    overlayButton.frame = CGRectMake(0.0f, 0.0f, self.overlayView.frame.size.width, self.overlayView.frame.size.height);
    overlayButton.titleLabel.textColor = [UIColor colorWithRed:60.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:1.0f];
    [overlayButton addTarget:self
                      action:@selector(overlayButtonTouchUpInside:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:overlayButton];
    self.overlayButton = overlayButton;
    
    // location Button
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(self.mapView.frame.size.width - X_MARGIN - BUTTON_SIZE_WIDTH, self.mapView.frame.size.height - Y_MARGIN - BUTTON_SIZE_HEIGHT - overlayrHeight, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    [locationButton setBackgroundImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [locationButton setContentMode:UIViewContentModeScaleAspectFit];
    [locationButton addTarget:self
                       action:@selector(locationButtonTouchUpInside:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:locationButton];
    self.locationButton = locationButton;
    
    // plus Button
    UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.locationButton.frame.origin.x, self.locationButton.frame.origin.y - Y_MARGIN - BUTTON_SIZE_HEIGHT, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [plusButton setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [plusButton setContentMode:UIViewContentModeScaleAspectFit];
    [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [plusButton addTarget:self
                   action:@selector(plusButtonTouchUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:plusButton];
    self.plusButton = plusButton;
    
    // plus View
    UIView *plusView = [[UIView alloc] initWithFrame:CGRectMake(plusButton.frame.origin.x, plusButton.frame.origin.y - (BUTTON_SIZE_HEIGHT * 3) - (Y_MARGIN * 3), BUTTON_SIZE_WIDTH, (BUTTON_SIZE_HEIGHT*3) + (Y_MARGIN * 3))];
    plusView.hidden = YES;
    [self.mapView addSubview:plusView];
    self.plusView = plusView;

    // Travel Add Button
    UIButton *travelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [travelButton setBackgroundImage:[UIImage imageNamed:@"travel"] forState:UIControlStateNormal];
    [travelButton setContentMode:UIViewContentModeScaleAspectFit];
    [travelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [travelButton addTarget:self
                     action:@selector(travelButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.plusView addSubview:travelButton];
    self.travelButton = travelButton;
    
    // album Button
    UIButton *albumButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, travelButton.frame.size.height + Y_MARGIN, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [albumButton setBackgroundImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
    [albumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [albumButton addTarget:self
                     action:@selector(albumButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.plusView addSubview:albumButton];
    self.albumButton = albumButton;
    
    // Location Add Button
    UIButton *locationAddButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, albumButton.frame.origin.y + BUTTON_SIZE_HEIGHT + Y_MARGIN, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [locationAddButton setBackgroundImage:[UIImage imageNamed:@"addLocation"] forState:UIControlStateNormal];
    [locationAddButton setContentMode:UIViewContentModeScaleAspectFit];
    [locationAddButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [locationAddButton addTarget:self
                    action:@selector(locationAddButtonTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.plusView addSubview:locationAddButton];
    self.locationAddButton = locationAddButton;
    
    // 설정 버튼
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(X_MARGIN, Y_MARGIN*2, BUTTON_SIZE_WIDTH, TEXTFIELD_HEIGHT)];
    [menuButton addTarget:self
                       action:@selector(menuButtonTouchUpInside:)
             forControlEvents:UIControlEventTouchUpInside];
    menuButton.backgroundColor = [UIColor whiteColor];
    [menuButton setImage:[UIImage imageNamed:@"Menu_icon"] forState:UIControlStateNormal];
    [self.mapView addSubview:menuButton];
    self.menuButton = menuButton;
    
    // 구글지도 검색 텍스트 필드
    // ##SJ x좌표를 settingsButton 가로 길이로 했는데 정확하게 되질 않는다....
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(X_MARGIN + menuButton.frame.size.width, menuButton.frame.origin.y, self.mapView.frame.size.width-menuButton.frame.size.width - (X_MARGIN*2), TEXTFIELD_HEIGHT)];
    [searchField addTarget:self
                    action:@selector(searchFieldDidChange:)
          forControlEvents:UIControlEventEditingDidBegin];
    searchField.placeholder = @"Google 지도 검색";
    searchField.borderStyle = UITextBorderStyleNone;
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.keyboardType = UIReturnKeyDone;
    [self.mapView addSubview:searchField];
    self.searchField = searchField;
    self.searchField.delegate = self;
    
    // Tap Gesture
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(appearanceSearchBar:)];
    [self.mapView addGestureRecognizer:tapGestureRecognizer];
    
    UIButton *logOutButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 20, 20)];
    [logOutButton addTarget:self action:@selector(logoutButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    logOutButton.backgroundColor = [UIColor cyanColor];
    [self.mapView addSubview:logOutButton];
    self.logoutButton = logOutButton;
}

// 구글지도 만들어주는 메서드
- (void)createGoogleMapView {
    
    // location 설정 메서드
    [self travelLocationManager];
    
    // 화면에서 보는 영역?
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude
                                                            longitude:self.locationManager.location.coordinate.longitude
                                                                 zoom:5];
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.padding = UIEdgeInsetsMake(0.0f, 0.0f, overlayrHeight, 0.0f);
    self.view = self.mapView;
}

- (void)travelLocationManager {
    // 현재 나의 위치 정보 가져오기.
    // nil일 경우에만
    if (self.locationManager == nil)
        self.locationManager = [[CLLocationManager alloc] init];
    
    // 델리게이트
    self.locationManager.delegate = self;
    // 로케이션 정확도 (배터리로 동작할 때 권장되는 가장 수준높은 정확도)
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 거리 필터 구성. 어느 정도 거리의 위치변화가 생겼을 때 어플이 알람을 받을지 말지 설정하는 프로퍼티. (1500미터)
    self.locationManager.distanceFilter = 1500.0;
    
    
    // 사용중인 위치 정보 요청 (사용할때만)
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // 위도
    DLog(@"latitude : %f", self.locationManager.location.coordinate.latitude);
    // 경도
    DLog(@"longitude : %f", self.locationManager.location.coordinate.longitude);
}

// PlusView Hidden method
- (void)plusViewHidden {
    self.plusView.hidden = !self.plusView.hidden;
}

- (void)travelListViewCall {
    TravelTableViewController *travelTabelViewController = [[TravelTableViewController alloc] init];
    travelTabelViewController.delegate = self;
    // Nivigation
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:travelTabelViewController];
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat: 2.0f] forKey:kCATransactionAnimationDuration];
    // change the camera, set the zoom, whatever.  Just make sure to call the animate* method.
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude zoom:16.0f];
    [self.mapView animateToCameraPosition:cameraPosition];
    [CATransaction commit];
    
    DLog(@"latiotude : %f", newLocation.coordinate.latitude);
    DLog(@"longitude : %f", newLocation.coordinate.longitude);
}

// Location 정보를 못가져 올때 Error Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DLog(@"LocationManager Error : %@", error);
}

#pragma mark - Action Method
/****************************************************************************
 *                                                                          *
 *                          Action Method                                   *
 *                                                                          *
 ****************************************************************************/
// PlusButton 눌렀을때.
- (void)plusButtonTouchUpInside:(UIButton *)sender {
    DLog(@"플러스 버튼 눌러!");
    [self plusViewHidden];
}

- (void)travelButtonTouchUpInside:(UIButton *)sender {
    DLog(@"여행 경로 추가");
    [self travelListViewCall];
    [self plusViewHidden];
}

- (void)albumButtonTouchUpInside:(UIButton *)sender {
    DLog(@"앨범 불러오기.");
    [self plusViewHidden];
    
    // 현재 활성화된 여행이 없을 경우 바로 여행리스트 접근.
    if ([TravelActivation defaultInstance].travelList == nil) {
        // Alert를 호출해 알려준다.
        CustomIOSAlertView *alert = [[CustomIOSAlertView alloc] init];
        [alert setContainerView:[self createAlertCustomView]];
        [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"확 인", @"취 소", nil]];
        [alert setDelegate:self];
        [alert setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
            if (buttonIndex == 0) {
                [self travelListViewCall];
            } else if (buttonIndex ==1 ) {
                DLog(@"취소");
            }
            [alertView close];
        }];
        
        [alert show];
        return;
    }
    // 사진권한 확인(앨범/설정화면으로 이동)
    [AuthorizationControll moveToMultiImageSelectFrom:self];
}

// 현재위치 찍어주는 이벤트
- (void)locationAddButtonTouchUpInside:(UIButton *)sender {
    DLog(@"현재위치 마커 찍기");
    [self plusViewHidden];
}

// 현재위치로 화면 이동 이벤트
- (void)locationButtonTouchUpInside:(UIButton *)sender {
    DLog(@"현재 위치로 이동!");
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        DLog(@"Location When In Use");
        [self.locationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        DLog(@"Location Not Determined");
        [self.locationManager requestWhenInUseAuthorization];
        
    }else if (status == kCLAuthorizationStatusDenied ||
               status == kCLAuthorizationStatusRestricted) {
        DLog(@"Location Denied");
        [ToastView showToastInView:[[UIApplication sharedApplication] keyWindow] withMessege:@"[설정] > [AirMap] > [위치] 접근을 허용해 주세요.\n 이곳을 누르면 설정화면으로 이동합니다."];
    }
}

// 메뉴버튼 이벤트
- (void)menuButtonTouchUpInside:(UIButton *)sender {
    DLog(@"메뉴 버튼 눌렀따!");
    MenuSlideViewController *menuSlideView = [[MenuSlideViewController alloc] init];
    [menuSlideView.view setFrame:CGRectMake(-self.view.frame.size.width, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    self.isSlideMenuOpen = YES;
    [self addChildViewController:menuSlideView];
    [self.view addSubview:menuSlideView.view];
    [UIView animateWithDuration:0.4 animations:^{
        [menuSlideView.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    }];
}

// 로그아웃 버튼 이벤트
- (void)logoutButtonTouchUpInside:(UIButton *)sender {
    DLog(@"로그아웃 버튼 클릭");
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
    [keychainItem resetKeychainItem];
    
    ViewController *loginViewController = [[ViewController alloc]init];
    loginViewController.modalPresentationStyle = UIModalPresentationPopover;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    [self presentViewController:nav animated:YES completion:nil];

    
    
    
}

// search Field Edit
- (void)searchFieldDidChange:(UITextField *)textField {
    DLog(@"searchField Edit");
    PlacesViewController *placesViewController = [[PlacesViewController alloc] init];
    placesViewController.delegate = self;
    [self presentViewController:placesViewController animated:NO completion:nil];
}

// 지도를 탭 했을 경우 UI들 숨기기 메서드
-(void)appearanceSearchBar:(UITapGestureRecognizer *)recognizer {
    if(self.isSlideMenuOpen ==NO){
        if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            // endEditing
            [self.view endEditing:YES];
            
            // searchBar가 숨어있지 않을 때
            if (self.isAnimating) {
                self.isAnimating = NO;
                [UIView animateWithDuration:0.5f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     // 애니메이션 진행 로직..
                                     // menu Button
                                     [self.menuButton setFrame:CGRectMake(self.menuButton.frame.origin.x,
                                                                          self.menuButton.frame.origin.y - 130.0f,
                                                                          self.menuButton.frame.size.width,
                                                                          self.menuButton.frame.size.height)];
                                     // search field
                                     [self.searchField setFrame:CGRectMake(self.searchField.frame.origin.x,
                                                                           self.searchField.frame.origin.y - 130.0f,
                                                                           self.searchField.frame.size.width,
                                                                           self.searchField.frame.size.height)];
                                     // plus Button
                                     [self.plusButton setAlpha:0.0f];
                                     // plus View
                                     [self.plusView setAlpha:0.0f];
                                     // loaction Button
                                     [self.locationButton setAlpha:0.0f];
                                     // status bar
                                     self.isStatusBarHidden = YES;
                                     // overlay view
                                     self.mapView.padding = UIEdgeInsetsMake(0.0, 0.0, -overlayrHeight, 0.0);
                                     [self.overlayView setFrame:CGRectMake(self.overlayView.frame.origin.x,
                                                                           self.overlayView.frame.origin.y + overlayrHeight,
                                                                           self.overlayView.frame.size.width,
                                                                           self.overlayView.frame.size.height)];
                                     [self setNeedsStatusBarAppearanceUpdate];
                                 } completion:^(BOOL finished) {
                                     // 애니메이션 완료 로직..
                                     DLog(@"Done 1");
                                 }];
            } else {
                self.isAnimating = YES;
                [UIView animateWithDuration:0.5f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     // 애니메이션 진행 로직..
                                     // menu Button
                                     [self.menuButton setFrame:CGRectMake(self.menuButton.frame.origin.x,
                                                                          self.menuButton.frame.origin.y + 130.0f,
                                                                          self.menuButton.frame.size.width,
                                                                          self.menuButton.frame.size.height)];
                                     // search field
                                     [self.searchField setFrame:CGRectMake(self.searchField.frame.origin.x,
                                                                           self.searchField.frame.origin.y + 130.0f,
                                                                           self.searchField.frame.size.width,
                                                                           self.searchField.frame.size.height)];
                                     // plus Button
                                     [self.plusButton setAlpha:1.0f];
                                     // plus View
                                     if (![self.plusView isHidden]) {
                                         self.plusView.hidden = !self.plusView.hidden;
                                     }
                                     [self.plusView setAlpha:1.0f];
                                     // loaction Button
                                     [self.locationButton setAlpha:1.0f];
                                     // status bar
                                     self.isStatusBarHidden = NO;
                                     // overlay view
                                     self.mapView.padding = UIEdgeInsetsMake(0.0f, 0.0f, overlayrHeight, 0.0f);
                                     [self.overlayView setFrame:CGRectMake(self.overlayView.frame.origin.x,
                                                                           self.overlayView.frame.origin.y - overlayrHeight,
                                                                           self.overlayView.frame.size.width,
                                                                           self.overlayView.frame.size.height)];
                                     
                                     [self setNeedsStatusBarAppearanceUpdate];
                                 } completion:^(BOOL finished) {
                                     // 애니메이션 완료 로직..
                                     DLog(@"Done 2");
                                 }];
            }
        }else{
            
        }
    }
}
// bottom overlay Button 클릭 이벤트
- (void)overlayButtonTouchUpInside:(UIButton *)sender {
    DLog(@"overlayButton TouchUp");
    // 현재 활성화된 여행이 없을 경우 바로 여행리스트 접근.
    if ([TravelActivation defaultInstance].travelList == nil) {
        [self travelListViewCall];
        return;
    }
    // Activity되어 있는 여행 리스트를 보여준다.
    TravelDetailViewController *travelDetailViewController = [[TravelDetailViewController alloc] initWithTravelList:[TravelActivation defaultInstance].travelList];
    travelDetailViewController.overLayFlag = YES;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:travelDetailViewController];
    [self presentViewController:navi animated:YES completion:nil];
}

// status bar
- (BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

#pragma mark - CustomIOSAlertView Method, Delegate
// AlertView에 보여지는 CustomView
- (UIView *)createAlertCustomView
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 00.f, 290.0f, 100.0f)];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, customView.frame.size.width, customView.frame.size.height)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont systemFontOfSize:15.0f];
    textLabel.text = @"선택 된 여행이 없습니다.\n확인을 누르시면 여행생성 화면으로 이동합니다.";
    [customView addSubview:textLabel];
    return customView;
}
// CustomIOSAlertView Delegate
- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

#pragma mark - GMSMapViewDelegate
/****************************************************************************
 *                                                                          *
 *                          GMSMapView Delegate                             *
 *                                                                          *
 ****************************************************************************/

#pragma mark - TravelTableViewController Delegate
- (void)selectTravelTitle:(NSString *)title {
    [self.overlayButton setTitle:title forState:UIControlStateNormal];
}

@end
