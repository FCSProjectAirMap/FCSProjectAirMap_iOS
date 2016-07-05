//
//  MapViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 5..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <GMSMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) GMSMutablePath *path;
@property (nonatomic) CLLocationManager *locationManager;

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
    
    [self createGoogleMapView];
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


#pragma mark - GMSMapViewDelegate
/****************************************************************************
 *                                                                          *
 *                          GMSMapView Delegate                             *
 *                                                                          *
 ****************************************************************************/

@end
