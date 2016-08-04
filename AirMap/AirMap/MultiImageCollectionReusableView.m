//
//  MultiImageCollectionReusableView.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/28/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "MultiImageCollectionReusableView.h"

@implementation MultiImageCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self creatAndUpdateLatout];
    }
    return self;
}

- (void)creatAndUpdateLatout {
    
    // 장소 라벨1 생성
    self.detailPlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, self.frame.size.width - 100, 20)];
    self.detailPlaceLabel.backgroundColor = [UIColor clearColor];
    self.detailPlaceLabel.textColor = [UIColor blackColor];
    self.detailPlaceLabel.font = [UIFont systemFontOfSize:14.0f];
    self.detailPlaceLabel.textAlignment = NSTextAlignmentLeft;
    self.detailPlaceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.detailPlaceLabel];
   
    // 장소 라벨2 생성
    self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, self.frame.size.width - 100, 10)];
    self.placeLabel.backgroundColor = [UIColor clearColor];
    self.placeLabel.textColor = [UIColor blackColor];
    self.placeLabel.font = [UIFont systemFontOfSize:12.0f];
    self.placeLabel.textAlignment = NSTextAlignmentLeft;
    self.placeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.placeLabel];

    // 시간 라벨 생성
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, 35, 95, 10)];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor blackColor];
    self.dateLabel.font = [UIFont systemFontOfSize:12.0f];
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    self.dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.dateLabel];
    
}


@end
