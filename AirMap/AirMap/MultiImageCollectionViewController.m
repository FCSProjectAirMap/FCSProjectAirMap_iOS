//
//  MultiImageCollectionViewController.m
//  PhotoCollectionTest
//
//  Created by Mijeong Jeon on 7/4/16.
//  Copyright © 2016 Mijeong Jeon. All rights reserved.
//

#import "MultiImageCollectionViewController.h"

@interface MultiImageCollectionViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *imageCollectionView;
@property (strong, nonatomic) MultiImageDataCenter *imageDataCenter;

@end

@implementation MultiImageCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";
const CGFloat spacing = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatCollectionView];
    [self navigationControllerSetUp];
    self.imageDataCenter = [[MultiImageDataCenter alloc] init];

}


#pragma mark - <UICollectionView>
- (void)creatCollectionView {
    
    // collectionViewFlowLayout 생성
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    // collectionView 생성_뷰 전체 사이즈 설정 및 viewLayout 설정
    self.imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
    
    [self.imageCollectionView setBackgroundColor:[UIColor whiteColor]];

    // collectionView delegate, dataSoucre 설정
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.dataSource = self;
    
    [self.imageCollectionView setAllowsSelection:YES];
    [self.imageCollectionView setAllowsMultipleSelection:YES];
    
    // 메인 뷰에 collectionView 올리기
    [self.view addSubview:self.imageCollectionView];
    
    // 셀 클래스 등록(MultiImageCollectionViewCell)
    [self.imageCollectionView registerClass:[MultiImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

#pragma mark - <UICollectionViewDataSource>
// 셀 개수 설정
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageDataCenter loadFetchResult].count;
}
// 셀 내용 설정
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // custom cell 생성
    
    MultiImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MultiImageCollectionViewCell alloc] init];
    }
    
    // 이미지 asset 생성
    PHAsset *imageAsset = [self.imageDataCenter loadFetchResult][indexPath.row];
    
    // 이미지 매니저를 통한 이미지 가져오기(
    cell.tag = indexPath.row;
    [[PHCachingImageManager defaultManager] requestImageForAsset:imageAsset
                                               targetSize:CGSizeMake(150,150)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                               
                                                if (cell.tag == indexPath.row) {
                                                cell.imageViewInCell.image = result;
                                                }
    }];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    NSLog(@"seleted");
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    [cell setSelected:YES];
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"deseleted");
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    [cell setSelected:NO];
//}


#pragma mark - <UICollectionViewDelegateFlowLayout>
// 셀 크기 조절
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat lengthForItem = (self.view.frame.size.width - spacing * 2) / 3;
    
    return CGSizeMake(lengthForItem, lengthForItem);
}

// 가로 줄 간격 조절
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return spacing;
}

// 세로 줄 간격 조절
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return spacing;
}


#pragma mark - <UINavigationController>
// 네비게이션 컨트롤러 바 설정
- (void)navigationControllerSetUp {
    // 컨트롤러 바 제목 설정
    self.navigationItem.title = @"Camera Roll";
    // 컨트롤러 버튼 설정
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:nil];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
}

- (void)cancelAction:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
