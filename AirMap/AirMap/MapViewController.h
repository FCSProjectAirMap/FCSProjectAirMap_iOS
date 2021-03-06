//
//  MapViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 5..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlacesViewController.h"
#import "TravelTableViewController.h"
#import "MultiImageCollectionViewController.h"
#import "MenuSlideViewController.h"
#import "AuthorizationControll.h"
#import "TravelActivation.h"
#import "TravelTopView.h"
#import "TravelBottomView.h"
#import "rootViewControllerObject.h"

@import GoogleMaps;

@interface MapViewController : UIViewController
<GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, PlacesViewControllerDelegate, TravelTopViewDelegate, TravelBottomViewDelegate,UIGestureRecognizerDelegate>


@property (nonatomic) UIView *blackScreen;

- (void) runSpinAnimationOnView:(UIButton*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;

@end
