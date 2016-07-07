//
//  MapViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 5..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MapViewController.h"
#import "MultiImageCollectionViewController.h"

const CGFloat BUTTON_SIZE_WIDTH = 60.0f;
const CGFloat BUTTON_SIZE_HEIGHT = 60.0f;

@interface MapViewController () <GMSMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) GMSMutablePath *path;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, weak) UIButton *plusButton;
@property (nonatomic, weak) UIButton *cameraButton;
@property (nonatomic, weak) UIButton *locationAddButton;
@property (nonatomic, weak) UIView *plusView;

@end

@implementation MapViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.path = [GMSMutablePath path];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 구글 지도 만들어 주기.
    [self createGoogleMapView];
    // view 만들어 주기.
    [self createView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - General Method
/****************************************************************************
 *                                                                          *
 *                          General Method                                  *
 *                                                                          *
 ****************************************************************************/
// plus, camer, location button create
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
    [cameraButton setTitle:@"앨범" forState:UIControlStateNormal];
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
}
// 구글지도 만들어주는 메서드
- (void)createGoogleMapView {
    // 현재 나의 위치 정보 가져오기.
    self.locationManager = [[CLLocationManager alloc] init];
    
    // delegate Connect
    self.locationManager.delegate = self;
    // 사용중인 위치 정보 요청
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // 현재위치 업데이트
    [self.locationManager startUpdatingHeading];
    
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
    NSLog(@"플러스 버튼 눌러!");
    self.plusView.hidden = !self.plusView.hidden;
}

- (void)cameraButtonTouchUpInside:(UIButton *)sender {
    NSLog(@"앨범 불러오기.");
    self.plusView.hidden = !self.plusView.hidden;
    
    // 사진권한 확인(앨범/설정화면으로 이동)
    [AuthorizationControll moveToMultiImageSelectFrom:self];
}

- (void)locationAddButtonTouchUpInside:(UIButton *)sender {
    NSLog(@"현재위치 찍기");
    self.plusView.hidden = !self.plusView.hidden;
}


#pragma mark - GMSMapViewDelegate
/****************************************************************************
 *                                                                          *
 *                          GMSMapView Delegate                             *
 *                                                                          *
 ****************************************************************************/

@end
