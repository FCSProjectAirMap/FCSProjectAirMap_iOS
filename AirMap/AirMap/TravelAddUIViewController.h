//
//  TravelAddUIViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 7..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TravelAddUIViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *travelName;

@end
