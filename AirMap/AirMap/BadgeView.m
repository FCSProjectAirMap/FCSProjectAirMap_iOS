//
//  BadgeView.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "BadgeView.h"

@interface BadgeView ()

@property (strong, nonatomic) UIView *badgeView;

@end


@implementation BadgeView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    return self;
}

// 텍스트 라벨 설정
- (UILabel *)textLabel {
    
    if (!self.badgeLabel) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        label.alpha = 1.0f;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.userInteractionEnabled = NO;
        [self addSubview:label];
        
        self.badgeLabel = label;
    }
    return self.badgeLabel;
}

- (UIView *)createBadgeView {
    
    if (!self.badgeView) {
        
    BadgeView *badgeView = [[BadgeView alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
    
    UIColor *color = [[UIColor alloc] initWithRed:255/255 green:255/255 blue:00/255 alpha:1.0];
    badgeView.backgroundColor = color;
    
    self.badgeValue = 3;
        
    badgeView.textLabel.text = [NSString stringWithFormat:@"%ld", self.badgeValue];
    badgeView.layer.cornerRadius = 10.0;
    badgeView.userInteractionEnabled = NO;
    badgeView.layer.borderWidth = 1;
    badgeView.layer.borderColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1.0].CGColor;
       
    self.badgeView = badgeView;
    }
    
    return self.badgeView;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
