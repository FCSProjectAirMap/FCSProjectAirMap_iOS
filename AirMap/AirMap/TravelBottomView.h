//
//  TravelBottomView.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 27..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TravelBottomViewDelegate <NSObject>

- (void)didSelectTravelPreviousButton:(nullable UIButton *) sender;
- (void)didSelectTravelNextButton:(nullable UIButton *) sender;
- (void)didSelectTravelMakeButton:(nullable UIButton *) sender;
- (void)didSelectTravelAlbumButton:(nullable UIButton *) sender;

@end

@interface TravelBottomView : UIView

@property (nonatomic, weak, nullable) id <TravelBottomViewDelegate> delegate;

@end
