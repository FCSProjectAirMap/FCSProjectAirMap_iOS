//
//  MapViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 5..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MapViewController.h"

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

@property (nonatomic, weak) UITextField *searchField;
@property (nonatomic, weak) UIButton *menuButton;

@property (nonatomic) BOOL isAnimating;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 구글 지도 만들어 주기.
    [self createGoogleMapView];
    // view 만들어 주기.
    [self setupUI];
    
    self.path = [GMSMutablePath path];
    self.isAnimating = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
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
    
    const CGFloat BUTTON_SIZE_WIDTH = 48.0f;
    const CGFloat BUTTON_SIZE_HEIGHT = 48.0f;
    const CGFloat X_MARGIN = 10.0f;
    const CGFloat Y_MARGIN = 10.0f;
    const CGFloat TEXTFIELD_HEIGHT = 45.0f;
    
    // plus Button
    UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(self.mapView.frame.size.width - X_MARGIN - BUTTON_SIZE_WIDTH, self.mapView.frame.size.height - Y_MARGIN - BUTTON_SIZE_HEIGHT, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [plusButton setTitle:@"+" forState:UIControlStateNormal];
    [plusButton setBackgroundColor:[UIColor colorWithRed:250/225.0f
                                                   green:225.0/225.0f
                                                    blue:0.0/225.0f
                                                   alpha:1.0f]];
    [plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [plusButton addTarget:self
                   action:@selector(plusButtonTouchUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:plusButton];
    self.plusButton = plusButton;
    
    // plus View
    UIView *plusView = [[UIView alloc] initWithFrame:CGRectMake(plusButton.frame.origin.x, plusButton.frame.origin.y - BUTTON_SIZE_HEIGHT*3, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT*3)];
    plusView.hidden = YES;
    [self.mapView addSubview:plusView];
    self.plusView = plusView;

    // Travel Add Button
    UIButton *travelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [travelButton setTitle:@"여행" forState:UIControlStateNormal];
    [travelButton setBackgroundColor:[UIColor colorWithRed:250/225.0f
                                                     green:225.0/225.0f
                                                      blue:0.0/225.0f
                                                     alpha:1.0f]];
    [travelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [travelButton addTarget:self
                     action:@selector(travelButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.plusView addSubview:travelButton];
    self.travelButton = travelButton;
    
    // album Button
    UIButton *albumButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, travelButton.frame.size.height, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [albumButton setTitle:@"앨범" forState:UIControlStateNormal];
    [albumButton setBackgroundColor:[UIColor colorWithRed:250/225.0f
                                                    green:225.0/225.0f
                                                     blue:0.0/225.0f
                                                    alpha:1.0f]];
    [albumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [albumButton addTarget:self
                     action:@selector(albumButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.plusView addSubview:albumButton];
    self.albumButton = albumButton;
    
    // Location Add Button
    UIButton *locationAddButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, albumButton.frame.size.height + BUTTON_SIZE_HEIGHT, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [locationAddButton setTitle:@"위치" forState:UIControlStateNormal];
    [locationAddButton setBackgroundColor:[UIColor colorWithRed:250/225.0f
                                                          green:225.0/225.0f
                                                           blue:0.0/225.0f
                                                          alpha:1.0f]];
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
    
    // location Button
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(X_MARGIN, menuButton.frame.origin.y + menuButton.frame.size.height + Y_MARGIN, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    [locationButton setImage:[UIImage imageNamed:@"gps_icon"] forState:UIControlStateNormal];
//    [locationButton setTitle:@"L" forState:UIControlStateNormal];
//    [locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [locationButton setBackgroundColor:[UIColor yellowColor]];
    [locationButton addTarget:self
                       action:@selector(locationButtonTouchUpInside:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:locationButton];
    self.locationButton = locationButton;
    
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
}

// 구글지도 만들어주는 메서드
- (void)createGoogleMapView {
    // 현재 나의 위치 정보 가져오기.
    self.locationManager = [[CLLocationManager alloc] init];
    
    // delegate Connect
    self.locationManager.delegate = self;
    // 사용중인 위치 정보 요청 (항상)
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    // 현재위치 업데이트
    [self.locationManager startUpdatingLocation];
    
    // 위도
    DLog(@"latitude : %f", self.locationManager.location.coordinate.latitude);
    // 경도
    DLog(@"longitude : %f", self.locationManager.location.coordinate.longitude);
    
    // 화면에서 보는 영역?
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude
                                                            longitude:self.locationManager.location.coordinate.longitude
                                                                 zoom:5];
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    [self.mapView setDelegate:self];
    [self.mapView setMyLocationEnabled:YES];
    self.view = self.mapView;
    
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
    self.plusView.hidden = !self.plusView.hidden;
}

- (void)travelButtonTouchUpInside:(UIButton *)sender {
    DLog(@"여행 경로 추가");
    TravelTableViewController *travelTabelViewController = [[TravelTableViewController alloc] init];
    // Nivigation
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:travelTabelViewController];
    [self presentViewController:navi animated:YES completion:nil];
    self.plusView.hidden = !self.plusView.hidden;
}

- (void)albumButtonTouchUpInside:(UIButton *)sender {
    DLog(@"앨범 불러오기.");
    self.plusView.hidden = !self.plusView.hidden;
    
    // 사진권한 확인(앨범/설정화면으로 이동)
    [AuthorizationControll moveToMultiImageSelectFrom:self];
}

// 현재위치 찍어주는 이벤트
- (void)locationAddButtonTouchUpInside:(UIButton *)sender {
    DLog(@"현재위치 마커 찍기");
    self.plusView.hidden = !self.plusView.hidden;
}

// 현재위치로 화면 이동 이벤트
- (void)locationButtonTouchUpInside:(UIButton *)sender {
    DLog(@"현재 위치로 이동!");
    // 현재위치 업데이트
    [self.locationManager startUpdatingLocation];
    if (!self.locationManager.location || !CLLocationCoordinate2DIsValid(self.locationManager.location.coordinate)) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat: 2.0f] forKey:kCATransactionAnimationDuration];
    // change the camera, set the zoom, whatever.  Just make sure to call the animate* method.
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:16.0f];
    [self.mapView animateToCameraPosition:cameraPosition];
    [CATransaction commit];
}

// 메뉴버튼 이벤트
- (void)menuButtonTouchUpInside:(UIButton *)sender {
    DLog(@"메뉴 버튼 눌렀따!");
    MenuSlideViewController *menuSlideView = [[MenuSlideViewController alloc] init];
    [menuSlideView.view setFrame:CGRectMake(-self.view.frame.size.width, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self addChildViewController:menuSlideView];
    [self.view addSubview:menuSlideView.view];
    [UIView animateWithDuration:0.4 animations:^{
        [menuSlideView.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    }];
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
                                 [self.plusView setAlpha:1.0f];
                                 // loaction Button
                                 [self.locationButton setAlpha:1.0f];
                             } completion:^(BOOL finished) {
                                 // 애니메이션 완료 로직..
                                 DLog(@"Done 2");
                             }];
        }
    }
}

#pragma mark - GMSMapViewDelegate
/****************************************************************************
 *                                                                          *
 *                          GMSMapView Delegate                             *
 *                                                                          *
 ****************************************************************************/

@end
