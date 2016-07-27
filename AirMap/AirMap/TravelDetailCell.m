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
@property (nonatomic, strong) UIImageView *countryImageView;
@property (nonatomic, strong) UILabel *creationDate;
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
    self.creationDate.text = _travelDetailInfoDictionary[@"timezone_date"];
    self.countryLabel.text = _travelDetailInfoDictionary[@"country"];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    const CGFloat LABEL_MARGIN = 10.0f;
    
    CGFloat imageHeight = [[self.travelDetailInfoDictionary objectForKey:@"imageHeight"] floatValue];
    
    // content Image View
    self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, imageHeight - 60.0f)];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentImageView setClipsToBounds:YES];
    [self.contentView addSubview:self.contentImageView];
    
    // bottom View
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.contentImageView.bounds.size.height, self.bounds.size.width, self.contentView.bounds.size.height - self.contentImageView.bounds.size.height)];
    [self.contentView addSubview:self.bottomView];
    
    // creationDate Label
    self.creationDate = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN, 0.0f, self.bottomView.bounds.size.width- LABEL_MARGIN, self.bottomView.bounds.size.height/2)];
    self.creationDate.textColor = [UIColor blackColor];
    self.creationDate.textAlignment = NSTextAlignmentLeft;
    [self.bottomView addSubview:self.creationDate];
    
    // country Label
    self.countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN, self.creationDate.bounds.size.height, self.creationDate.bounds.size.width - LABEL_MARGIN, self.bottomView.bounds.size.height/2)];
    self.countryLabel.textColor = [UIColor blackColor];
    self.countryLabel.textAlignment = NSTextAlignmentLeft;
    [self.bottomView addSubview:self.countryLabel];
    
    // country Image View
    UIImage *countryImage = [UIImage imageNamed:@"South Korea"];
    self.countryImageView = [[UIImageView alloc] initWithImage:countryImage];
    self.countryImageView.frame = CGRectMake(self.contentImageView.frame.size.width - 60.0f - 20.0f, self.contentImageView.frame.size.height - 30.0f, 60.0f, 60.0f);
    self.countryImageView.layer.cornerRadius = self.countryImageView.frame.size.width / 2;
    self.countryImageView.layer.borderWidth = 1.0f;
    self.countryImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.countryImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.countryImageView];
    
    [self setInfoWithInfodic];
}


@end
