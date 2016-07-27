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
        // 장소 라벨 생성
        self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, self.frame.size.width - 100, 30)];
        self.placeLabel.backgroundColor = [UIColor clearColor];
        self.placeLabel.textColor = [UIColor blackColor];
        self.placeLabel.font = [UIFont systemFontOfSize:15.0f];
        self.placeLabel.textAlignment = NSTextAlignmentLeft;
        self.placeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.placeLabel];

        // 시간 라벨 생성
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, 15, 95, 30)];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.textColor = [UIColor blackColor];
        self.dateLabel.font = [UIFont systemFontOfSize:12.0f];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.dateLabel];
    }
    return self;
}

@end
