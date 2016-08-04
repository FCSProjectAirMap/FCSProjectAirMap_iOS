//
//  TravelTopViewController.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 27..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TravelTopViewDelegate <NSObject>

- (void)didSelectMenuSlideButton:(nullable UIButton *) sender;
- (void)didSelectTravelTitleButton:(nullable UIButton *) sender;
- (void)didSelectPlaceSearchButton:(nullable UIButton *) sender;
- (void)didSelectTravelImageListButton:(nullable UIButton *) sender;

@end

@interface TravelTopView : UIView

- (void)travelImageListButtonIconImage:(nullable UIImage *)iconImage;

@property (nonatomic, weak, nullable) id <TravelTopViewDelegate> delegate;

@end
