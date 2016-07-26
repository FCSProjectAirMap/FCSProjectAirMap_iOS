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
#import "LoginViewController.h"
#import <GoogleMaps/GoogleMaps.h>

static const CGFloat overlayrHeight = 45.0f;

@interface MapViewController ()

@property (nonatomic) GMSMapView *mapView;;

//@property (nonatomic) GMSMutablePath *path;
@property (nonnull) NSMutableArray *markers;
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
@property (nonatomic, strong) TravelActivation *travelActivation;

@property (nonatomic, weak) UIButton *logoutButton;

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isStatusBarHidden;

@end

@implementation MapViewController

#pragma mark - View LifeCycel
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // marker Array
    self.markers = [NSMutableArray arrayWithCapacity:1];
    
    // 활성화된 싱글톤 객체
    self.travelActivation = [TravelActivation defaultInstance];
    
    // 구글 지도 만들어 주기.
    [self createGoogleMapView];
    
    // view 만들어 주기.
    [self setupUI];
    
    self.isAnimating = YES;
    
    //로그아웃 Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DisappearBlurWhenLogout:) name:@"clickLogoutButton" object:nil];
    
    // 경로 Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(travelTrackingDraw:) name:@"travelTrackingDraw" object:nil];
    
    // Title Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(travelTitleChange:) name:@"travelTitleChange" object:nil];
    
    // Tracking Clear Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(travelTrackingClear:) name:@"travelTrackingClear" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchbackground:) name:@"NotiForParentViewTouch" object:nil];
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
    // Nivigation
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:travelTabelViewController];
    [self presentViewController:navi animated:YES completion:nil];
}

// fit Bounds
- (void)didFitBounds {
    GMSCoordinateBounds *bounds;
    for (GMSMarker *marker in self.markers) {
        if (bounds == nil) {
            bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position
                                                          coordinate:marker.position];
        }
        bounds = [bounds includingCoordinate:marker.position];
    }
    
    if (bounds == nil)
        return;
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
    [self.mapView moveCamera:update];
}
#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
//    [CATransaction begin];
//    [CATransaction setValue:[NSNumber numberWithFloat: 2.0f] forKey:kCATransactionAnimationDuration];
    // change the camera, set the zoom, whatever.  Just make sure to call the animate* method.
//    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude zoom:16.0f];
//    [self.mapView animateToCameraPosition:cameraPosition];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"경 고"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        // title font customize
        NSString *messege = @"선택된 여행이 없습니다!\n\"확인\"을 누르시면 \n여행 경로 화면으로 이동합니다.";
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:messege];
        [title addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                               NSFontAttributeName:[UIFont fontWithName:@"NanumGothicOTF" size:13.0]}
                       range:NSMakeRange(0, messege.length )];
        [alert setValue:title forKey:@"attributedTitle"];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"확 인"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self travelListViewCall];
                                                         }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취 소"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                             }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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
   
//SH ANIMATION
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapView.myLocationEnabled = YES;
        });
        
        if(((fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>0.0001))&&((fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>0.0001))&&(_mapView.camera.zoom == 14.5)&&(_mapView.camera.bearing ==0) &&(_mapView.camera.viewingAngle ==40)){
        
        
            CAMediaTimingFunction *curve =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            CABasicAnimation *animation1;
            
            animation1 = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraViewingAngleKey];
            animation1.duration = 2.0f;
            animation1.timingFunction = curve;
            animation1.fromValue = @40.0;
            animation1.toValue = @0.0;
            animation1.removedOnCompletion = NO;
            animation1.fillMode = kCAFillModeForwards;

            [_mapView.layer addAnimation:animation1 forKey:kGMSLayerCameraViewingAngleKey];
            
            
        }else if(((fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>0.0001))&&((fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>0.0001))&&(_mapView.camera.zoom == 14.5)&&(_mapView.camera.bearing ==0) &&(_mapView.camera.viewingAngle ==0)){
            
            CAMediaTimingFunction *curve =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            CABasicAnimation *animation2;

            
                        animation2 = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraViewingAngleKey];
                        animation2.duration = 2.0f;
                        animation2.timingFunction = curve;
                        animation2.fromValue = @0.0;
                        animation2.toValue = @40.0;
                        animation2.removedOnCompletion = NO;
                        animation2.fillMode = kCAFillModeForwards;
                        [_mapView.layer addAnimation:animation2 forKey:kGMSLayerCameraViewingAngleKey];
            
        }else if(((fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>0.0001))&&((fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>0.0001))&&(_mapView.camera.zoom == 14.5)&&(_mapView.camera.bearing ==0) &&((_mapView.camera.viewingAngle !=0)||(_mapView.camera.viewingAngle !=40))){
            
        }
        else{
    if((fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)<=0.6 &&fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>0.001)&&(fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)<=0.6&&fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)>0.001)){
            CAMediaTimingFunction *curve =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            CABasicAnimation *animation1;
            CABasicAnimation *animation2;
            CABasicAnimation *animation3;
            CABasicAnimation *animation4;
        
            animation1 = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraLatitudeKey];
            animation1.duration = 2.0f;
            animation1.timingFunction = curve;
            animation1.toValue = @(self.mapView.myLocation.coordinate.latitude);
            animation1.removedOnCompletion = NO;
            animation1.fillMode = kCAFillModeForwards;
            [_mapView.layer addAnimation:animation1 forKey:kGMSLayerCameraLatitudeKey];
            
            animation2 = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraLongitudeKey];
            animation2.duration = 2.0f;
            animation2.timingFunction = curve;
            animation2.toValue = @(self.mapView.myLocation.coordinate.longitude);
            animation2.removedOnCompletion = NO;
            animation2.fillMode = kCAFillModeForwards;
            [_mapView.layer addAnimation:animation2 forKey:kGMSLayerCameraLongitudeKey];
        
            animation3 = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraViewingAngleKey];
            animation3.duration = 2.0f;
            animation3.timingFunction = curve;
            animation3.toValue = @40.0;
            animation3.removedOnCompletion = NO;
            animation3.fillMode = kCAFillModeForwards;
            [_mapView.layer addAnimation:animation3 forKey:kGMSLayerCameraViewingAngleKey];

        animation4 = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraBearingKey];
        animation4.duration=2.0f;
        animation4.timingFunction = curve;
//        animation4.fromValue=@(self.mapView.camera.bearing);
        animation4.toValue = @0.0;
        animation4.removedOnCompletion = NO;
        animation4.fillMode = kCAFillModeForwards;
        [_mapView.layer addAnimation:animation4 forKey:kGMSLayerCameraBearingKey];
        
        CGFloat zoom = _mapView.camera.zoom;
        NSArray *keyValues = @[@(zoom), @14.5f];
        CAKeyframeAnimation *keyFrameAnimation =
        [CAKeyframeAnimation animationWithKeyPath:kGMSLayerCameraZoomLevelKey];
        keyFrameAnimation.duration = 2.0f;
        keyFrameAnimation.values = keyValues;
        keyFrameAnimation.removedOnCompletion =NO;
        keyFrameAnimation.fillMode = kCAFillModeForwards;
        [_mapView.layer addAnimation:keyFrameAnimation forKey:kGMSLayerCameraZoomLevelKey];
    }else{
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat: 0.0f] forKey:kCATransactionAnimationDuration];
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude longitude:self.mapView.myLocation.coordinate.longitude zoom:14.5 bearing:0 viewingAngle:40];
        [self.mapView animateToCameraPosition:cameraPosition];
        [CATransaction commit];
        
        
    }
        }
        
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        DLog(@"Location Not Determined");
        [self.locationManager requestWhenInUseAuthorization];
        
    }else if (status == kCLAuthorizationStatusDenied ||
               status == kCLAuthorizationStatusRestricted) {
        DLog(@"Location Denied");
        [ToastView showToastInView:[[UIApplication sharedApplication] keyWindow] withMessege:@"[설정] > [TravelMaker] > [위치] 접근을 허용해 주세요.\n 이곳을 누르면 설정화면으로 이동합니다."];
    }
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    [self.locationButton setUserInteractionEnabled:NO];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.locationButton setUserInteractionEnabled:YES];
}

// 메뉴버튼 이벤트
- (void)menuButtonTouchUpInside:(UIButton *)sender {
    DLog(@"메뉴 버튼 눌렀따!");
    MenuSlideViewController *menuSlideView = [[MenuSlideViewController alloc] init];
    [menuSlideView.view setFrame:CGRectMake(-self.view.frame.size.width, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self addChildViewController:menuSlideView];
    [self.view addSubview:menuSlideView.view];
    
    // create effect
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIView *blackScreen = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [blackScreen setAlpha:0];
    [blackScreen setBackgroundColor:[UIColor blackColor]];
    [self.mapView addSubview:blackScreen];
    self.blackScreen = blackScreen;
    
    // add effect to an effect view
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
//    [effectView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.mapView addSubview:effectView];
//    [effectView setAlpha:0];
//    self.effectView = effectView;
    
    [UIView animateWithDuration:0.4 animations:^{ [blackScreen setAlpha:0.4f];
        
    }];
    
    [UIView animateWithDuration:0.4 animations:^{
        [menuSlideView.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view bringSubviewToFront:menuSlideView.view];

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
-(void)appearanceUI {
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
                             self.locationButton.layer.shadowColor = [UIColor blackColor].CGColor;
                             self.locationButton.layer.shadowOffset = CGSizeMake(-1.5, 0);
                             self.locationButton.layer.shadowOpacity = 0.6;
                             self.locationButton.layer.shadowRadius = 2.0;
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

#pragma mark - GMSMapViewDelegate
/****************************************************************************
 *                                                                          *
 *                          GMSMapView Delegate                             *
 *                                                                          *
 ****************************************************************************/
// mapview tap delegate
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self appearanceUI];
}

// Marker선택시 UIView 보여주는 Delegate Method
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//    TravelList *travelList = self.travelActivation.travelList;
    // ##SJ Test
    RLMResults *resultArray = [ImageData objectsWhere:@"creation_date == %@", marker.title];
    if (resultArray.count > 0) {
        ImageData *imageData = resultArray[0];
        UIView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData.image]];
        imageView.frame = CGRectMake(0.0f, 0.0f, 150.0f, 150.0f);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        return imageView;
    }
    return nil;
}

#pragma mark - Notification
// OverLayView에 title
- (void)travelTitleChange:(NSNotification *)notification {
    self.overlayButton.titleLabel.font = [UIFont fontWithName:@"NanumGothicOTF" size:15.0];
    [self.overlayButton setTitle:notification.object forState:UIControlStateNormal];
}

-(void)DisappearBlurWhenLogout:(NSNotification *)notification{
    [self.blackScreen removeFromSuperview];
}

// google 지도에 경로 그리기.
- (void)travelTrackingDraw:(NSNotification *)notification {
    // 경로 지우기.
    [self travelTrackingClear:notification];
    
    TravelList *travelList = self.travelActivation.travelList;
    // 시간차순으로 정렬
    RLMResults *result = [travelList.image_datas sortedResultsUsingProperty:@"timestamp" ascending:YES];
    
    GMSMutablePath *path = [GMSMutablePath path];
    GMSMarker *marker = nil;
    
    for (ImageData *imageData in result) {
        // Marker
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(imageData.latitude, imageData.longitude);
        marker = [GMSMarker markerWithPosition:position];
        marker.title = imageData.creation_date;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marker"]];
        imageView.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
        marker.iconView = imageView;
        marker.map = _mapView;
        [self.markers addObject:marker];
        [path addCoordinate:position];
    }
    
    // 점선 설정
    NSArray *styles = @[[GMSStrokeStyle solidColor:[UIColor colorWithRed:60.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:1.0f]],
                        [GMSStrokeStyle solidColor:[UIColor clearColor]]];
    NSArray *lengths = @[@1000, @500];
    
    GMSPolyline *poly = [GMSPolyline polylineWithPath:path];
    poly.geodesic = YES;
    poly.strokeWidth = 2.5f;
    // kGmsLengthGeodesic : 최단거리
    poly.spans = GMSStyleSpans(poly.path, styles, lengths, kGMSLengthGeodesic);
    poly.map = _mapView;
    
    // fit bounds
    [self didFitBounds];
}

- (void)travelTrackingClear:(NSNotification *)notification {
    // 지도위에 마커와 라인을 지워준다.
    [self.mapView clear];
    [self.markers removeAllObjects];
    
}

// 메뉴슬라이드에서 터치 백그라운드 했을때 blur effect뷰의 애니메이션을 노티피케이션 Selector로 받음.
-(void)touchbackground:(NSNotification *)notification{
    
    [UIView animateWithDuration:0.4 animations:^{[self.blackScreen setAlpha:0];
    }completion:^(BOOL finished){
        [self.blackScreen removeFromSuperview];
    }];
    
}


@end
