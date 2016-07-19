//
//  TravelDetailViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 10..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TravelDetailCell.h"
#import "UserInfo.h"

@interface TravelDetailViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL overLayFlag;

- (instancetype)initWithTravelList:(TravelList *)travelList;

@end
