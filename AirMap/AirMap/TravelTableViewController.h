//
//  TravelTableViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 7..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TravelDetailViewController.h"
#import "AuthorizationControll.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "UserInfo.h"
#import "TravelActivation.h"
#import "KeychainItemWrapper.h"

@protocol TravelTableViewControllerDelegate <NSObject>

- (void)selectTravelTitle:(NSString *)title;

@end

@interface TravelTableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource,MGSwipeTableCellDelegate>

@property (nonatomic, strong) id <TravelTableViewControllerDelegate> delegate;

@end
