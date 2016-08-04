//
//  TravelBottomView.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 27..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelBottomView.h"

@interface TravelBottomView()

@property (nonatomic, weak) UIButton *travelPreviousButton;
@property (nonatomic, weak) UIButton *travelNextButton;
@property (nonatomic, weak) UIButton *travelMakeButton;
@property (nonatomic, weak) UIButton *travelAlbumButton;

@end

@implementation TravelBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

// UI
- (void)setupUI {
    
    const CGFloat BUTTON_SIZE_WIDTH = 50.0f;
    const CGFloat BUTTON_SIZE_HEIGHT = 50.0f;
    const CGFloat X_MARGIN = 10.0f;
//    const CGFloat Y_MARGIN = 10.0f;
    
    // travel previous Button
    UIButton *travelPreviousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    travelPreviousButton.frame = CGRectMake(X_MARGIN, (self.frame.size.height - BUTTON_SIZE_HEIGHT)/2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    [travelPreviousButton setBackgroundImage:[UIImage imageNamed:@"previous_icon"] forState:UIControlStateNormal];
    [travelPreviousButton addTarget:self
                             action:@selector(travelPreviousTouchUpInside:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:travelPreviousButton];
    self.travelPreviousButton = travelPreviousButton;
    
    // travel next Button
    UIButton *travelNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    travelNextButton.frame = CGRectMake(travelPreviousButton.frame.size.width + X_MARGIN*3, (self.frame.size.height - BUTTON_SIZE_HEIGHT)/2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    [travelNextButton setBackgroundImage:[UIImage imageNamed:@"next_icon"] forState:UIControlStateNormal];
    [travelNextButton addTarget:self
                         action:@selector(travelNextTouchUpInside:)
               forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:travelNextButton];
    self.travelNextButton = travelNextButton;
    
    // travel album Button
    UIButton *travelAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    travelAlbumButton.frame = CGRectMake(self.frame.size.width - BUTTON_SIZE_WIDTH - X_MARGIN, (self.frame.size.height - BUTTON_SIZE_HEIGHT)/2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    [travelAlbumButton setBackgroundImage:[UIImage imageNamed:@"Picture_icon"] forState:UIControlStateNormal];
    [travelAlbumButton addTarget:self
                          action:@selector(travelAlbumTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:travelAlbumButton];
    self.travelAlbumButton = travelAlbumButton;
    
    // travel make Button
    UIButton *travelMakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    travelMakeButton.frame = CGRectMake(travelAlbumButton.frame.origin.x - BUTTON_SIZE_WIDTH - X_MARGIN, (self.frame.size.height - BUTTON_SIZE_HEIGHT)/2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    [travelMakeButton setBackgroundImage:[UIImage imageNamed:@"Make_icon"] forState:UIControlStateNormal];
    [travelMakeButton addTarget:self
                         action:@selector(travelMakeTouchUpInside:)
               forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:travelMakeButton];
    self.travelMakeButton = travelMakeButton;
}

#pragma mark - Action Method & Delegate Method
- (void)travelPreviousTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectTravelPreviousButton:)]) {
        [self.delegate didSelectTravelPreviousButton:sender];
    }
}

- (void)travelNextTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectTravelNextButton:)]) {
        [self.delegate didSelectTravelNextButton:sender];
    }
}

- (void)travelAlbumTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectTravelAlbumButton:)]) {
        [self.delegate didSelectTravelAlbumButton:sender];
    }
}

- (void)travelMakeTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectTravelMakeButton:)]) {
        [self.delegate didSelectTravelMakeButton:sender];
    }
}


@end
