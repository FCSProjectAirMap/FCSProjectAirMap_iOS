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

static const CGFloat bottomViewHeight = 54.0f;
static const CGFloat topViewHeight = 74.0f;

@interface MapViewController ()

@property (nonatomic) GMSMapView *mapView;;

//@property (nonatomic) GMSMutablePath *path;
@property (nonnull) NSMutableArray *markers;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) TravelTopView *travelTopView;
@property (nonatomic, strong) TravelBottomView *travelBottomView;

@property (nonatomic, weak) UIButton *locationButton;

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
    
    // travel Top View
    self.travelTopView = [[TravelTopView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.mapView.frame.size.width, topViewHeight)];
    self.travelTopView.delegate = self;
    self.travelTopView.backgroundColor = [UIColor whiteColor];
    self.travelTopView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.travelTopView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.travelTopView.layer.shadowOpacity = 0.5f;
    [self.mapView addSubview:self.travelTopView];
    
    // travel Bottom View
    self.travelBottomView = [[TravelBottomView alloc] initWithFrame:CGRectMake(0.0f, self.mapView.frame.size.height - bottomViewHeight, self.mapView.frame.size.width, bottomViewHeight)];
    self.travelBottomView.delegate = self;
    self.travelBottomView.backgroundColor = [UIColor whiteColor];
    self.travelBottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.travelBottomView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.travelBottomView.layer.shadowOpacity = 0.5f;
    [self.mapView addSubview:self.travelBottomView];
    
    // location Button
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(self.mapView.frame.size.width - X_MARGIN - BUTTON_SIZE_WIDTH, self.mapView.frame.size.height - Y_MARGIN - BUTTON_SIZE_HEIGHT - bottomViewHeight, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    [locationButton setBackgroundImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [locationButton setContentMode:UIViewContentModeScaleAspectFit];
    [locationButton addTarget:self
                       action:@selector(locationTouchUpInside:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:locationButton];
    self.locationButton = locationButton;
    
   // SH TEST EDGE SWIPE
//    // menuSlide Pangesture
//    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
//                                                                                              action:@selector(handlePan:)];
//    [pan setEdges:UIRectEdgeLeft];
//    [pan setDelegate:self];
//    [self.mapView addGestureRecognizer:pan];

}
   // SH TEST EDGE SWIPE
//-(void)handlePan:(UIScreenEdgePanGestureRecognizer *)sender
//{
//    // create effect
//    
//    MenuSlideViewController *menuSlideView = [[MenuSlideViewController alloc] init];
//    [menuSlideView.view setFrame:CGRectMake(-self.view.frame.size.width, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
//    [self addChildViewController:menuSlideView];
//    [self.view addSubview:menuSlideView.view];
//    
//    UIView *blackScreen = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [blackScreen setAlpha:0];
//    [blackScreen setBackgroundColor:[UIColor blackColor]];
//    [self.mapView addSubview:blackScreen];
//    self.blackScreen = blackScreen;
//    
//    if (sender.state == UIGestureRecognizerStateBegan)
//    {
//        DLog(@"시작");
//        
//    } else if (sender.state == UIGestureRecognizerStateChanged)
//    {
//        if(menuSlideView.view.frame.origin.x >0 )
//        {
//            [sender setEnabled:NO];
//        }
//    }
//    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed)
//    {
//        
//        [UIView animateWithDuration:0.4 animations:^{ [blackScreen setAlpha:0.4f];
//            }];
//
//        
//        [UIView animateWithDuration:0.4 animations:^{
//            [menuSlideView.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
//            [self.view bringSubviewToFront:menuSlideView.view];
//            
//        }];
//        [sender setEnabled:NO];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchBackgroundSender:) name:@"NotiForSenderON" object:nil];
//        
//    }
//}
//
//-(void)touchBackgroundSender : (NSNotification *)notification
//{
//    
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    
//    return YES;
//}

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
    self.mapView.padding = UIEdgeInsetsMake(0.0f, 0.0f, bottomViewHeight, 0.0f);
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

// 여행경로 뷰 호출 메서드
- (void)travelListViewCall:(BOOL) alertFlag {
    TravelTableViewController *travelTabelViewController = [[TravelTableViewController alloc] init];
    // Nivigation
    UINavigationController *travelTableViewNavi = [[UINavigationController alloc] initWithRootViewController:travelTabelViewController];
    [self presentViewController:travelTableViewNavi animated:YES completion:^{
        if (alertFlag) {
            // 여행경로창이 호출 되고 Alert창을 호출한다.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"travelListMake" object:nil];
        }
    }];
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
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:70.0f];
    [self.mapView moveCamera:update];
}

#pragma mark - Travel Top View Delegate

// 상단 뷰 메뉴 슬라이드 버튼
- (void)didSelectMenuSlideButton:(UIButton *) sender {
    DLog(@"MenuSlide");
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

// 상단 뷰 타이블 버튼
- (void)didSelectTravelTitleButton:(UIButton *) sender {
    DLog(@"TravelTitle");
    [self travelListViewCall:NO];
}

// 상단 뷰 지역검색 버튼
- (void)didSelectPlaceSearchButton:(UIButton *) sender {
    DLog(@"PlaceSearch");
    PlacesViewController *placesViewController = [[PlacesViewController alloc] init];
    [self presentViewController:placesViewController animated:NO completion:^{
        
    }];
}

// 상단 뷰 이미지 리스트 버튼
- (void)didSelectTravelImageListButton:(UIButton *) sender {
    DLog(@"TravelImageList");
    // 현재 활성화된 여행이 없을 경우 바로 여행리스트 접근.
    if ([TravelActivation defaultInstance].travelList == nil) {
        // AlertView로 안내 후 리스트 창을 띄어준다.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"경 고"
                                                                       message:@"현재 활성화된 여행이 없습니다.\n\"확인\"을 누르시면 여행리스트 화면으로 이동합니다."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"확인"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self travelListViewCall:YES];
                                                         }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                             }];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 싱글톤 객체가 이전 rootView객체를 참조하고 있다가 바뀔때마다 교체해준다.
    if ([rootViewControllerObject defaultInstance].rootViewController == nil) {
        
        // Root View를 맵 뷰에서 여행경로 디테일 뷰로 변경.
        TravelDetailViewController *travelDetailViewController = [[TravelDetailViewController alloc] initWithTravelList:[TravelActivation defaultInstance].travelList];
        // 기존에 메모리에 생성되어있던 MapViewController는 다른곳에서 참조 하고 있는다.
        UIViewController *rootViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        [rootViewControllerObject defaultInstance].rootViewController = rootViewController;
        
        // root View를 디테일 뷰로 교체.
        [[[UIApplication sharedApplication] delegate] window].rootViewController =  travelDetailViewController;
    } else {
        
        UIViewController *rootViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        [[[UIApplication sharedApplication] delegate] window].rootViewController = [rootViewControllerObject defaultInstance].rootViewController;
        [rootViewControllerObject defaultInstance].rootViewController = rootViewController;
    }
}

#pragma mark - Travel Bottom View Delegate
// 하단 뷰 이전 여행경로 버튼
- (void)didSelectTravelPreviousButton:(UIButton *) sender {
    DLog(@"Travel Previous");
}

// 하단 뷰 다음 여행경로 버튼
- (void)didSelectTravelNextButton:(UIButton *) sender {
    DLog(@"Travel Next");
}

// 하단 뷰 여행경로 생성 버튼
- (void)didSelectTravelMakeButton:(UIButton *) sender {
    DLog(@"Travel Make");
    // 상단 여행 제복 버튼 눌렀을 경우.
    [self travelListViewCall:YES];
}

// 하단 뷰 앨범 버튼
- (void)didSelectTravelAlbumButton:(UIButton *) sender {
    DLog(@"Travel Album");
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
                                                             [self travelListViewCall:YES];
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

#pragma mark - UIContorl Event Method
/****************************************************************************
 *                        UIContorl Event Method                            *
 ****************************************************************************/
// 현재위치로 화면 이동 이벤트
- (void)locationTouchUpInside:(UIButton *)sender {
    DLog(@"현재 위치로 이동!");
    [self runSpinAnimationOnView:sender duration:1.0 rotations:0.5 repeat:0];
   
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        DLog(@"Location When In Use");
        [self.locationManager startUpdatingLocation];
   
//SH ANIMATION
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapView.myLocationEnabled = YES;
        });
        
        if(((fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>=0))&&((fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>=0))&&(_mapView.camera.zoom == 14.5)&&(_mapView.camera.bearing ==0) &&(_mapView.camera.viewingAngle ==40)){
        
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
            
            [self runSpinAnimationOnView:sender duration:1.0 rotations:-0.03 repeat:0];
            
        }else if(((fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>=0))&&((fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>=0))&&(_mapView.camera.zoom == 14.5)&&(_mapView.camera.bearing ==0) &&(_mapView.camera.viewingAngle ==0)){
            
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
            
        }else if(((fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>=0))&&((fabs(_mapView.camera.target.latitude - self.mapView.myLocation.coordinate.latitude)<=0.001)&&(fabs(_mapView.camera.target.longitude - self.mapView.myLocation.coordinate.longitude)>=0))&&(_mapView.camera.zoom == 14.5)&&(_mapView.camera.bearing ==0) &&((_mapView.camera.viewingAngle !=0)||(_mapView.camera.viewingAngle !=40))){
            
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

//SH LocationButton Animation Test
- (void) runSpinAnimationOnView:(UIButton*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue =[[view.layer presentationLayer]valueForKeyPath:@"transform.rotation.z"] ;
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.0 * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;

    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    [self.locationButton setUserInteractionEnabled:NO];
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.locationButton setUserInteractionEnabled:YES];
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
                             // top View
                             [self.travelTopView setAlpha:0.0f];
                             
                             // loaction Button
                             [self.locationButton setAlpha:0.0f];
                             
                             // status bar
                             self.isStatusBarHidden = YES;
                             
                             // bottom view
                             self.mapView.padding = UIEdgeInsetsMake(0.0, 0.0, -bottomViewHeight, 0.0);
                             [self.travelBottomView setFrame:CGRectMake(self.travelBottomView.frame.origin.x,
                                                                        self.travelBottomView.frame.origin.y + bottomViewHeight,
                                                                        self.travelBottomView.frame.size.width,
                                                                        self.travelBottomView.frame.size.height)];
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
                             // top View
                             [self.travelTopView setAlpha:1.0f];
                             
                             // loaction Button
                             [self.locationButton setAlpha:1.0f];
                             self.locationButton.layer.shadowColor = [UIColor blackColor].CGColor;
                             self.locationButton.layer.shadowOffset = CGSizeMake(-1.5, 0);
                             self.locationButton.layer.shadowOpacity = 0.6;
                             self.locationButton.layer.shadowRadius = 2.0;
                             
                             // status bar
                             self.isStatusBarHidden = NO;
                             // overlay view
                             self.mapView.padding = UIEdgeInsetsMake(0.0f, 0.0f, bottomViewHeight, 0.0f);
                             [self.travelBottomView setFrame:CGRectMake(self.travelBottomView.frame.origin.x,
                                                                        self.travelBottomView.frame.origin.y - bottomViewHeight,
                                                                        self.travelBottomView.frame.size.width,
                                                                        self.travelBottomView.frame.size.height)];
                             
                             [self setNeedsStatusBarAppearanceUpdate];
                         } completion:^(BOOL finished) {
                             // 애니메이션 완료 로직..
                             DLog(@"Done 2");
                         }];
    }
}

// status bar
- (BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

#pragma mark - GMSMapViewDelegate
/****************************************************************************
 *                          GMSMapView Delegate                             *
 ****************************************************************************/
// mapview tap delegate
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self appearanceUI];
}

// Marker선택시 UIView 보여주는 Delegate Method
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {

    // ##SJ 이미지 리스트의 전체 where절을 사용하는것보다 하나의 여행폴더에 이미지의 최대 갯수가 30개라 for문을 돌리는게 더 효율적이라고 생각.
    // 이미지 timestapm로 매칭.
    TravelList *travelList = self.travelActivation.travelList;
    for (ImageData *imageData in travelList.image_datas) {
        if ([marker.title isEqualToString:[NSString stringWithFormat:@"%ld", imageData.timestamp]]) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData.image]];
            imageView.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            return imageView;
        }
    }
    return nil;
}

#pragma mark - Notification
-(void)DisappearBlurWhenLogout:(NSNotification *)notification{
    [self.blackScreen removeFromSuperview];
}

// google 지도에 경로 그리기.
- (void)travelTrackingDraw:(NSNotification *)notification {
    // 경로 지우기.
    [self travelTrackingClear:notification];
    
    TravelList *travelList = self.travelActivation.travelList;
    // 시간차순으로 정렬
    RLMResults *result = [travelList.image_datas sortedResultsUsingProperty:@"timezone_date" ascending:YES];
    
    GMSMutablePath *path = [GMSMutablePath path];
    GMSMarker *marker = nil;
    
    for (ImageData *imageData in result) {
        // Marker
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(imageData.latitude, imageData.longitude);
        marker = [GMSMarker markerWithPosition:position];
        // ##SJ imageData의 creation_date는 사용하지 않음..!!
        // marker.title = imageData.creation_date;
        marker.title = [NSString stringWithFormat:@"%ld", imageData.timestamp];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marker"]];
        imageView.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
        marker.iconView = imageView;
        marker.map = _mapView;
        [self.markers addObject:marker];
        [path addCoordinate:position];
    }
    
    GMSPolyline *poly = [GMSPolyline polylineWithPath:path];
    poly.strokeColor = [UIColor brownColor];
    poly.strokeWidth = 3.0f;
    poly.map = _mapView;
    
    // fit bounds
    [self didFitBounds];
}

// 지도위에 마커와 라인을 지워준다.
- (void)travelTrackingClear:(NSNotification *)notification {
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
