//
//  MapViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 5..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MapViewController.h"

const CGFloat BUTTON_SIZE_WIDTH = 60.0f;
const CGFloat BUTTON_SIZE_HEIGHT = 60.0f;

@interface MapViewController ()
<GMSMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) GMSMutablePath *path;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, weak) UIButton *plusButton;
@property (nonatomic, weak) UIButton *cameraButton;
@property (nonatomic, weak) UIButton *locationAddButton;
@property (nonatomic, weak) UIView *plusView;
@property (nonatomic, weak) UISearchBar *searchBar;

// ##SJ Test
@property (nonatomic) BOOL isAnimating;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 구글 지도 만들어 주기.
    [self createGoogleMapView];
    // view 만들어 주기.
    [self createView];
    
    self.path = [GMSMutablePath path];
    self.isAnimating = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [MapViewController removeGMSBlockingGestureRecognizerFromMapView:self.mapView];
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
- (void)createView {
    
    // plus Button
    UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, self.mapView.frame.size.height*0.9, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [plusButton setTitle:@"더하기" forState:UIControlStateNormal];
    [plusButton setBackgroundColor:[UIColor blackColor]];
    [plusButton addTarget:self
                   action:@selector(plusButtonTouchUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:plusButton];
    self.plusButton = plusButton;
    
    // plus View
    UIView *plusView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, plusButton.frame.origin.y - BUTTON_SIZE_HEIGHT*2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT*2)];
    plusView.hidden = YES;
    [self.mapView addSubview:plusView];
    self.plusView = plusView;
    
    // camera Button
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [cameraButton setTitle:@"카메라" forState:UIControlStateNormal];
    [cameraButton setBackgroundColor:[UIColor redColor]];
    [cameraButton addTarget:self
                     action:@selector(cameraButtonTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.plusView addSubview:cameraButton];
    self.cameraButton = cameraButton;
    
    // Location Add Button
    UIButton *locationAddButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, cameraButton.frame.size.height, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT)];
    [locationAddButton setTitle:@"위치" forState:UIControlStateNormal];
    [locationAddButton setBackgroundColor:[UIColor redColor]];
    [locationAddButton addTarget:self
                    action:@selector(locationAddButtonTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.plusView addSubview:locationAddButton];
    self.locationAddButton = locationAddButton;
    
    // 구글지도 검색 텍스트 필드
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20.0f, 30.0f, self.mapView.frame.size.width-40.0f, 40.0f)];
    searchBar.placeholder = @"지역 검색";
    searchBar.alpha = 0.9f;
    [self.mapView addSubview:searchBar];
    self.searchBar = searchBar;
    
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
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    [self.mapView setDelegate:self];
    [self.mapView setMyLocationEnabled:YES];
    [self.mapView.settings setMyLocationButton:YES];
    [self.mapView.settings setCompassButton:YES];
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

- (void)cameraButtonTouchUpInside:(UIButton *)sender {
    DLog(@"앨범 불러오기.");
    self.plusView.hidden = !self.plusView.hidden;
}

- (void)locationAddButtonTouchUpInside:(UIButton *)sender {
    DLog(@"현재위치 찍기");
    self.plusView.hidden = !self.plusView.hidden;
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
                                 // search Bar
                                 [self.searchBar setFrame:CGRectMake(self.searchBar.frame.origin.x,
                                                                     self.searchBar.frame.origin.y - 130.0f,
                                                                     self.searchBar.frame.size.width,
                                                                     self.searchBar.frame.size.height)];
                                 // plus Button
                                 [self.plusButton setAlpha:0.0f];
                                 // loaction Button
                                 [self.mapView.settings setMyLocationButton:NO];
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
                                 [self.searchBar setFrame:CGRectMake(self.searchBar.frame.origin.x,
                                                                     self.searchBar.frame.origin.y + 130.0f,
                                                                     self.searchBar.frame.size.width,
                                                                     self.searchBar.frame.size.height)];
                                 // plus Button
                                 [self.plusButton setAlpha:1.0f];
                                 // loaction Button
                                 [self.mapView.settings setMyLocationButton:YES];
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
