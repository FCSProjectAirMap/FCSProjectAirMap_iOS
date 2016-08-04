//
//  MenuSlideViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 8..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"

@interface MenuSlideViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource,SKSTableViewDelegate>

@property (nonatomic, strong) NSString *userID;


@property (nonatomic, weak) SKSTableView *tableView;
@end
