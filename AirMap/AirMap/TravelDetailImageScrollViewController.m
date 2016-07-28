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
@property (nonatomic, weak) UIButton *closeButton;

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
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)setupUI {

    // Scroll View
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)];
    scrollView.pagingEnabled = YES;
    scrollView.alwaysBounceVertical = NO;
    TravelList *travelList = [TravelActivation defaultInstance].travelList;
    RLMResults *result = [travelList.image_datas sortedResultsUsingProperty:@"timezone_date" ascending:YES];
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
    
    // Close Button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(10.0f, 32.0f, 50.0f, 50.0f);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"Close_icon"] forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont fontWithName:@"NanumGothic.otf" size:15.0f];
    [closeButton addTarget:self
                    action:@selector(closeTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
}

#pragma mark - UIControlEvent Method
- (void)closeTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
