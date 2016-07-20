//
//  BadgeView.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "BadgeView.h"

@interface BadgeView ()

@property (weak, nonatomic) UIView *badgeView;
@property (weak, nonatomic) UILabel *badgeLabel;
@property (nonatomic) NSInteger badgeValue;

@end

@implementation BadgeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(UpdateNotification:)
                                                     name:@"UpdateNotification"
                                                   object:nil];
        self.badgeValue = 1;
    }
    return self;
}

// 텍스트 라벨 설정
- (UILabel *)textLabel {
    
    if (!self.badgeLabel) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        label.alpha = 0.0f;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [[UIColor alloc] initWithRed:(CGFloat)60/255 green:(CGFloat)30/255 blue:(CGFloat)30/255 alpha:1.00];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.userInteractionEnabled = NO;
        [self addSubview:label];
        
        self.badgeLabel = label;
    }
    return self.badgeLabel;
}

// badgeView 생성
- (UIView *)createBadgeView {
    
    BadgeView *badgeView = [[BadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    badgeView.layer.cornerRadius = 10.0f;
    badgeView.userInteractionEnabled = NO;
    badgeView.textLabel.text = [NSString stringWithFormat:@"%ld", self.badgeValue];
    self.badgeView = badgeView;
    
    return self.badgeView;
}

// noti받고 값변화
- (void)updateBadgeValueWithAnimationInView {
    
    if (self.badgeValue > 0) {
        
        self.badgeView.backgroundColor =
        [[UIColor alloc] initWithRed:(CGFloat)250/255 green:(CGFloat)225/255 blue:(CGFloat)0/255 alpha:1.0f];
        self.alpha = 1.0f;
        self.textLabel.alpha = 1.0f;
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", self.badgeValue];
        
        // 값 변화시 뱃지 사이즈 커짐
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        animation.duration = 0.2f;
        animation.repeatCount = 1;
        animation.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
        animation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.2f, 1.2f)];
        
        [self.layer addAnimation:animation forKey:@"scale_up"];
        // 0일때 badge 숨김
    } else {
        [self removeBadgeView];
    }
}


- (NSInteger)badgeNumber {
    return self.badgeValue;
}

// 선택된 사진이 0장일때
- (void)removeBadgeView {
    self.badgeView.alpha = 0.0f;
    self.badgeValue = 0;
}

// notification 등록_선택된 사진개수 실시간 변화 감지
- (void)UpdateNotification:(NSNotification *)notification {
    self.badgeValue = [notification.object integerValue];
    [self updateBadgeValueWithAnimationInView];
}

// badgeValue 업데이트
- (void)updateBadgeValue:(NSInteger)value {
    self.badgeValue = value;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
