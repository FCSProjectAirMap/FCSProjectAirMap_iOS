//
//  TravelDetailCell.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 15..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelDetailCell.h"

@interface TravelDetailCell()

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UILabel *timezoneDateLabel;
@property (nonatomic, strong) UILabel *countryLabel;

@end

@implementation TravelDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTravelDetailInfoDictionary:(NSDictionary *)travelDetailInfoDictionary {
    _travelDetailInfoDictionary = travelDetailInfoDictionary;
    
    [self setInfoWithInfodic];
}

- (void)setInfoWithInfodic {
    self.contentImageView.image = _travelDetailInfoDictionary[@"image"];
    self.timezoneDateLabel.text = _travelDetailInfoDictionary[@"timezone_date"];
    self.countryLabel.text = _travelDetailInfoDictionary[@"country"];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat imageHeight = [[self.travelDetailInfoDictionary objectForKey:@"imageHeight"] floatValue];
    
    // content Image View
    self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, imageHeight - 50.0f)];
    self.contentImageView.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:self.contentImageView];
    
    // bottom View
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.contentImageView.bounds.size.height, self.bounds.size.width, self.bounds.size.height - self.contentImageView.bounds.size.height)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bottomView];
    
    // timezoneDateLabel
    self.timezoneDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 20.0f)];
    self.timezoneDateLabel.textColor = [UIColor blackColor];
    self.timezoneDateLabel.backgroundColor = [UIColor yellowColor];
    self.timezoneDateLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomView addSubview:self.timezoneDateLabel];
    
    // country Label
    self.countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.timezoneDateLabel.bounds.size.height, self.bounds.size.width, 20.0f)];
    self.countryLabel.textColor = [UIColor whiteColor];
    self.countryLabel.backgroundColor = [UIColor blackColor];
    self.countryLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomView addSubview:self.countryLabel];
    
    [self setInfoWithInfodic];
}


@end
