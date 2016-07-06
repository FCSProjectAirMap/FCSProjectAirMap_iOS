//
//  MultiImageCollectionViewCell.m
//  PhotoCollectionTest
//
//  Created by Mijeong Jeon on 7/4/16.
//  Copyright © 2016 Mijeong Jeon. All rights reserved.
//

#import "MultiImageCollectionViewCell.h"

@interface MultiImageCollectionViewCell ()

@property (strong, nonatomic) CAShapeLayer *overLayer;

@end


@implementation MultiImageCollectionViewCell

const CGFloat boundary = 3.0;

// cell 초기화
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

    self.imageViewInCell = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        
    self.imageViewInCell.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewInCell.clipsToBounds = YES;
    
    [self.contentView addSubview:self.imageViewInCell];
    
    [self overlayFill];
        
    }

    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageViewInCell.image = nil;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    // 셀 선택시
    if (selected) {
        [self.contentView.layer addSublayer:self.overLayer];
//        NSLog(@"select");
    // 재선택시
    } else {
        [self.overLayer removeFromSuperlayer];/////
//        NSLog(@"deslect");
    }
}


- (CAShapeLayer *)overlayFill {
    
    if (!self.overLayer) {
    
    // 테두리 생성
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.contentView.bounds];
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRect:CGRectMake(boundary, boundary, self.contentView.frame.size.width - 2 * boundary, self.contentView.frame.size.width - 2 * boundary)];
    
    [overlayPath appendPath:transparentPath];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    // 내부 레이어 생성
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = transparentPath.CGPath;
    fillLayer.fillColor = [UIColor colorWithWhite:-1 alpha:0.4].CGColor;
    
    // 외부 테두리 생성
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = overlayPath.CGPath;
    lineLayer.fillRule = kCAFillRuleEvenOdd;
    lineLayer.fillColor = [UIColor colorWithRed:255/255.0 green:240/255.0 blue:0/255.0 alpha:1].CGColor;
    
    self.overLayer = lineLayer;
    [self.overLayer addSublayer:fillLayer];
    
    }
    
    return self.overLayer;
}

@end
