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
@property (strong, nonatomic) BadgeView *badgeView;

@end

@implementation MultiImageCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";
const CGFloat spacing = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatCollectionView];
    [self navigationControllerSetUp];
    
    self.imageDataCenter = [MultiImageDataCenter sharedImageDataCenter];
    [self.imageDataCenter resetSelectedFiles];
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
    
    // cell, reusableView 클래스 등록
    [self.imageCollectionView registerClass:[MultiImageCollectionViewCell class]
                 forCellWithReuseIdentifier:reuseIdentifier];
    [self.imageCollectionView registerClass:[MultiImageCollectionReusableView class]
                 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                        withReuseIdentifier:@"HeaderView"];
}

#pragma mark - <UICollectionViewDataSource>
// 섹션 수 설정
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.imageDataCenter callCollectionResult].count;
}

// 셀 개수 설정
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //    return [self.imageDataCenter callFetchResult].count;
    PHFetchResult *result = [(PHFetchResult *)[self.imageDataCenter callCollectionAssetResutls] objectAtIndex:section];
    return result.count;
}

// 셀 내용 설정
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // custom cell 생성
    
    MultiImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MultiImageCollectionViewCell alloc] init];
    }
    
    //    // 이미지 asset 생성
    //    PHAsset *imageAsset = [self.imageDataCenter callFetchResult][indexPath.row];
    //
    //    // 이미지 매니저를 통한 이미지 가져오기
    //    cell.tag = indexPath.row;
    //    [[PHCachingImageManager defaultManager] requestImageForAsset:imageAsset
    //                                                      targetSize:CGSizeMake(150,150)
    //                                                     contentMode:PHImageContentModeAspectFill
    //                                                         options:nil
    //                                                   resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
    //
    //                                                       if (cell.tag == indexPath.row) {
    //                                                           cell.imageViewInCell.image = result;
    //                                                       }
    //                                                   }];
    // 이미지 컬렉션에서 asset생성
    PHAssetCollection *momentCollection = [self.imageDataCenter callCollectionResult][indexPath.section];
    PHFetchResult *momentAssets = [PHAsset fetchAssetsInAssetCollection:momentCollection options:nil];
    
    PHAsset *momentAsset = momentAssets[indexPath.row];
    
    cell.tag = indexPath.row;
    // 이미지 매니저를 통한 이미지 가져오기
    [[PHCachingImageManager defaultManager] requestImageForAsset:momentAsset targetSize:CGSizeMake(150, 150) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        cell.imageViewInCell.image = result;
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        MultiImageCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if (headerView == nil) {
            headerView = [[MultiImageCollectionReusableView alloc] init];
        }
        
        // headerView에 들어갈 장소, 날짜 텍스트 설정
        PHAssetCollection *moment = [[self.imageDataCenter callCollectionResult] objectAtIndex:indexPath.section];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        if (!moment.localizedTitle) {
            [headerView.placeLabel setText:[dateFormatter stringFromDate:moment.startDate]];
            [headerView.detailPlaceLabel setText:nil];
            [headerView.dateLabel setText:nil];
            reusableView = headerView;
        } else {
            [headerView.dateLabel setText:[dateFormatter stringFromDate:moment.startDate]];
            [headerView.detailPlaceLabel setText:moment.localizedTitle];
            [headerView.placeLabel setText:[moment.localizedLocationNames firstObject]];
            reusableView = headerView;
        }
    }
    return reusableView;
}

#pragma mark - <UICollectionViewDelegate>

// 10장 이상 선택시 셀 선택 제한, 총 30장 이상 일시 셀 선택 제한
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger savedImageNumber = [TravelActivation defaultInstance].travelList.image_datas.count;
    NSString *alertString = [NSString stringWithFormat:@"1개의 경로에는 30장까지 저장 가능합니다.\n 현재 %ld장 저장되어있습니다.", savedImageNumber];
    
    if ([self.badgeView badgeNumber] < 10) {
        if ([self.badgeView badgeNumber] + savedImageNumber < 30) {
            return YES;
        } else {
            [self showAlertWindow:YES withMessege:alertString withFlag:NO];
            return NO;
        }
        return YES;
    } else {
        // 경고
        [self showAlertWindow:YES withMessege:@"사진은 최대 10장까지 선택 가능합니다." withFlag:NO];
        return NO;
    }
}

// 사진이 선택되었을때 저장
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([self.badgeView badgeNumber] < 10) {
        //        PHAsset *selectedAsset = [self.imageDataCenter call][indexPath.row];
        PHAssetCollection *momentCollection = [self.imageDataCenter callCollectionResult][indexPath.section];
        PHFetchResult *momentAssets = [PHAsset fetchAssetsInAssetCollection:momentCollection options:nil];
        PHAsset *momentAsset = momentAssets[indexPath.row];
        
        [self.imageDataCenter addSelectedAsset:momentAsset];
        [cell setSelected:YES];
    } else {
        [cell setSelected:NO];
    }
    //    NSLog(@"%ld",[self.imageDataCenter callSelectedAssets].count);
}

// 재선택된 사진 빼기
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"deseleted");
    //    PHAsset *deSelectedAsset = [self.imageDataCenter callFetchResult][indexPath.row];
    PHAssetCollection *momentCollection = [self.imageDataCenter callCollectionResult][indexPath.section];
    PHFetchResult *momentAssets = [PHAsset fetchAssetsInAssetCollection:momentCollection options:nil];
    PHAsset *momentAsset = momentAssets[indexPath.row];
    
    [self.imageDataCenter removeSelectedAsset:momentAsset];
}


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

// header 크기 설정
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(30, 55);
}

// edge 크기 설정
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    UIEdgeInsets insets=UIEdgeInsetsMake(0, 0, 10, 10);
//    return insets;
//}

#pragma mark - <UINavigationController>
// 네비게이션 컨트롤러 바 설정
- (void)navigationControllerSetUp {
    
    self.navigationItem.title = @"특별한 순간";
    [self updateNavigationBarButtonItem];
}

// 컨트롤러 버튼 설정
- (void)updateNavigationBarButtonItem {
    
    // 오른쪽 선택 버튼
    self.badgeView = [[BadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    UIBarButtonItem *badgeButton = [[UIBarButtonItem alloc] initWithCustomView:[self.badgeView createBadgeView]];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"선택" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    
    // 왼쪽 나가기 버튼
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"나가기" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:doneButton, badgeButton, nil];
    self.navigationItem.rightBarButtonItem.tintColor
    = [[UIColor alloc] initWithRed:(CGFloat)60/255 green:(CGFloat)30/255 blue:(CGFloat)30/255 alpha:1.00];
    self.navigationItem.leftBarButtonItem.tintColor
    = [[UIColor alloc] initWithRed:(CGFloat)60/255 green:(CGFloat)30/255 blue:(CGFloat)30/255 alpha:1.00];
}

// 네비게이션 버튼 액션
-(void)doneAction:(UIButton *)sender {
    // 선택된 사진 메타데이터 추출
    [self.imageDataCenter extractMetadataFromImage];
    
    // GPS 정보가 없는 사진이 있을때 사용자에게 알림
    if ([[self.imageDataCenter callSelectedAssetsWithoutGPS] count] > 0) {
        
        [self showAlertWindow:YES withMessege:[NSString stringWithFormat:@"GPS 정보가 없는 사진 %ld장은\n 경로에서 제외됩니다.",
                                               [[self.imageDataCenter callSelectedAssetsWithoutGPS] count]] withFlag:YES];
        return;
    }
    
    //    __weak typeof(self) weakSelf = self;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        // 맵화면으로 돌아올때 notification 제거
        [[NSNotificationCenter defaultCenter] removeObserver:self.badgeView name:@"UpdateNotification" object:nil];
        // 선택된 파일 제거
        //        [weakSelf.imageDataCenter resetSelectedFiles];
        
        // ##SJ tracking Notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTrackingDraw" object:nil];
    }];
}

- (void)cancelAction:(UIButton *)sender {
    [self.imageDataCenter resetSelectedFiles];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Show Alert Window
// 선택된 사진이 10장 이상일때/GPS정보 없을때 alert띄우기
- (void)showAlertWindow:(BOOL)isShowAlert withMessege:(NSString *)messege withFlag:(BOOL)flag {
    
    if (isShowAlert) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        // title font customize
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:messege];
        [title addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"NanumGothicOTF" size:13.0]}
                       range:NSMakeRange(0, messege.length )];
        [alert setValue:title forKey:@"attributedTitle"];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // GPS정보가 없는 사진 유무에 따라 viewcontroller dismiss 시점 변경
            if (flag) {
                //                __weak typeof(self) weakSelf = self;
                
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    [[NSNotificationCenter defaultCenter] removeObserver:self.badgeView name:@"UpdateNotification" object:nil];
                    //                    [weakSelf.imageDataCenter resetSelectedFiles];
                    
                    // ##SJ Test
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"travelTrackingDraw" object:nil];
                }];
            }
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
