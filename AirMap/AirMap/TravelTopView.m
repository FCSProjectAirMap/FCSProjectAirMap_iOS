//
//  TravelTopViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 27..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelTopView.h"

@interface TravelTopView ()

@property (nonatomic, weak) UIButton *menuSlideButton;
@property (nonatomic, weak) UIButton *travelTitleButton;
@property (nonatomic, weak) UIButton *travelListTopButton;
@property (nonatomic, weak) UIButton *placeSearchButton;
@property (nonatomic, weak) UIButton *travelImageListButton;

@end

@implementation TravelTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // UI
        [self setupUI];
        
        // Title Notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(travelTitleChange:) name:@"travelTitleChange" object:nil];
    }
    return self;
}

// UI
- (void)setupUI {
    
    const CGFloat BUTTON_SIZE_WIDTH = 50.0f;
    const CGFloat BUTTON_SIZE_HEIGHT = 50.0f;
    const CGFloat X_MARGIN = 10.0f;
    const CGFloat Y_MARGIN = 10.0f;
    
    // menu button
    UIButton *menuSlideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuSlideButton.frame = CGRectMake(X_MARGIN, Y_MARGIN*2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    UIImage *menuImage = [UIImage imageNamed:@"menu_icon"];
    [menuSlideButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    [menuSlideButton addTarget:self
                        action:@selector(menuSlideTouchUpInside:)
              forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuSlideButton];
    self.menuSlideButton = menuSlideButton;
    
    // travel Image List Button
    UIButton *travelImageListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    travelImageListButton.frame = CGRectMake(self.frame.size.width - BUTTON_SIZE_WIDTH - Y_MARGIN, Y_MARGIN*2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    UIImage *listImage = [UIImage imageNamed:@"list_icon"];
    [travelImageListButton setBackgroundImage:listImage forState:UIControlStateNormal];
    [travelImageListButton addTarget:self
                              action:@selector(travelImageListTouchUpInside:)
                    forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:travelImageListButton];
    self.travelImageListButton = travelImageListButton;
    
    // place Search Button
    UIButton *placeSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    placeSearchButton.frame = CGRectMake(travelImageListButton.frame.origin.x - BUTTON_SIZE_WIDTH - Y_MARGIN, Y_MARGIN*2, BUTTON_SIZE_WIDTH, BUTTON_SIZE_HEIGHT);
    UIImage *searchImage = [UIImage imageNamed:@"search_icon"];
    [placeSearchButton setBackgroundImage:searchImage forState:UIControlStateNormal];
    [placeSearchButton addTarget:self
                          action:@selector(placeSearchTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:placeSearchButton];
    self.placeSearchButton = placeSearchButton;
    
    // travel Title Button
    UIButton *travelTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    travelTitleButton.frame = CGRectMake(menuSlideButton.frame.origin.x + BUTTON_SIZE_WIDTH, Y_MARGIN*2, placeSearchButton.frame.origin.x -(menuSlideButton.frame.origin.x + BUTTON_SIZE_WIDTH), BUTTON_SIZE_HEIGHT);
    [travelTitleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [travelTitleButton addTarget:self
                          action:@selector(travelTitleTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:travelTitleButton];
    self.travelTitleButton = travelTitleButton;
}

#pragma mark - Notification Method
- (void)travelTitleChange:(NSNotification *)notification {
    self.travelTitleButton.titleLabel.font = [UIFont fontWithName:@"NanumGothicOTF" size:15.0];
    [self.travelTitleButton setTitle:notification.object forState:UIControlStateNormal];

}

#pragma mark - Action Method & Delegate Method
- (void)menuSlideTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectMenuSlideButton:)]) {
        [self.delegate didSelectMenuSlideButton:sender];
    }
}

- (void)travelTitleTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectTravelTitleButton:)]) {
        [self.delegate didSelectTravelTitleButton:sender];
    }
}

- (void)placeSearchTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectPlaceSearchButton:)]) {
        [self.delegate didSelectPlaceSearchButton:sender];
    }
}

- (void)travelImageListTouchUpInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectTravelImageListButton:)]) {
        [self.delegate didSelectTravelImageListButton:sender];
    }
}

@end
