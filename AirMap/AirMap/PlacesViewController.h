//
//  PlacesViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 6..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMaps;

@protocol PlacesViewControllerDelegate <NSObject>

-(void)placesInfoShow:(GMSPlace *)place;

@end

@interface PlacesViewController : UIViewController

@property (nonatomic, weak) id <PlacesViewControllerDelegate> delegate;

@end
