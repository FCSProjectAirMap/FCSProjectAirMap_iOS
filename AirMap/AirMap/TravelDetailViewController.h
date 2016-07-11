//
//  TravelDetailViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 10..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"

@interface TravelDetailViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource,MGSwipeTableCellDelegate>

@property (nonatomic, strong) NSString *travelName;

// ##SJ Test
@property (nonatomic) NSMutableArray *dataDetailArray;

@end
