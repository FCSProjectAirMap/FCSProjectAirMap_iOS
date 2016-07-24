//
//  TravelDetailImageScrollViewController.m
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 22..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import "TravelDetailImageScrollViewController.h"

@interface TravelDetailImageScrollViewController ()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) NSInteger imageIndex;

@end

@implementation TravelDetailImageScrollViewController

- (instancetype)initWithImageIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        _imageIndex = index;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
    scrollView.pagingEnabled = YES;
    scrollView.alwaysBounceVertical = NO;
    TravelList *travelList = [TravelActivation defaultInstance].travelList;
    RLMResults *result = [travelList.image_datas sortedResultsUsingProperty:@"timestamp" ascending:YES];
    NSInteger index = 0;
    for (ImageData *imageData in result) {
        CGFloat xOrigin = index * self.view.frame.size.width;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        imageView.image = [[UIImage alloc] initWithData:imageData.image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
        ++index;
    }
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * travelList.image_datas.count, self.view.frame.size.height);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
}

@end
