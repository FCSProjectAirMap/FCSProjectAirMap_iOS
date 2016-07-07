//
//  BadgeView.h
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeView : UIView

@property (nonatomic) NSInteger badgeValue;
@property (weak, nonatomic) UILabel *badgeLabel;

- (UIView *)createBadgeView;


@end
