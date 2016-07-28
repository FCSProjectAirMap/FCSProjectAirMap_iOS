//
//  TravelDetailViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 10..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TravelDetailCell.h"
#import "TravelDetailImageScrollViewController.h"
#import "TravelTopView.h"
#import "TravelBottomView.h"
#import "rootViewControllerObject.h"

@interface TravelDetailViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, TravelTopViewDelegate, TravelBottomViewDelegate>

//- (instancetype)initWithTravelList:(TravelList *)travelList;

@end
