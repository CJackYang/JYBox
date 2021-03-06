//
//  JYShowBigImgViewController.m
//  Photos
//
//  Created by JackYang on 2017/10/17.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYShowBigImgViewController.h"
#import <Photos/Photos.h>
#import "JYBigImgCell.h"
#import "JYConst.h"
#import "JYAsset.h"
#import "PHPhotoLibrary+JYEXT.h"

@interface JYShowBigImgViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    
    UIButton *_navRightBtn;
    
    //底部view
    UIView   *_bottomView;
    UIButton *_btnOriginalPhoto;
    UIButton *_btnDone;
    //编辑按钮
    UIButton *_btnEdit;
    
    //双击的scrollView
    UIScrollView *_selectScrollView;
    NSInteger _currentPage;
    
    UIPanGestureRecognizer *_panGesture;
    
    BOOL _isFirstAppear;
    
    BOOL _hideNavBar;
    
    BOOL _isdraggingPhoto;
    
    //设备旋转前的index
    NSInteger _indexBeforeRotation;
    UICollectionViewFlowLayout *_layout;
    
    NSString *_modelIdentifile;
}

@end

@implementation JYShowBigImgViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"---- %s", __FUNCTION__);
}

- (instancetype)init
{
    if(self = [super init]) {
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
            self.automaticallyAdjustsScrollViewInsets = NO;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationCapturesStatusBarAppearance = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.clipsToBounds = YES;
    self.view.alpha = 0.0f;
    _isFirstAppear = YES;
    _currentPage = self.selectIndex+1;
    _indexBeforeRotation = self.selectIndex;
    self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, self.models.count];
    [self initNavBtns];
    [self initCollectionView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [_panGesture setMinimumNumberOfTouches:1];
    [_panGesture setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:_panGesture];
}

- (void)back:(id)btn
{
//    JYBigImgCell * cell = _collectionView.visibleCells.firstObject;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isFirstAppear) {
        return;
    }
    [_collectionView setContentOffset:CGPointMake((kViewWidth+kItemMargin)*_indexBeforeRotation, 0)];
    [self performPresentAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_isFirstAppear) {
        return;
    }
    _isFirstAppear = NO;
    [self reloadCurrentCell];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _layout.minimumLineSpacing = kItemMargin;
    _layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    _layout.itemSize = self.view.bounds.size;
    [_collectionView setCollectionViewLayout:_layout];
    
    _collectionView.frame = CGRectMake(-kItemMargin/2, 0, kViewWidth+kItemMargin, kViewHeight);
    
    [_collectionView setContentOffset:CGPointMake((kViewWidth+kItemMargin)*_indexBeforeRotation, 0)];
    
    CGRect frame = _hideNavBar?CGRectMake(0, kViewHeight, kViewWidth, 44):CGRectMake(0, kViewHeight-44, kViewWidth, 44);
    _bottomView.frame = frame;
    _btnEdit.frame = CGRectMake(kViewWidth/2-30, 7, 60, 30);
    _btnDone.frame = CGRectMake(kViewWidth - 82, 7, 70, 30);
}

#pragma mark - panGesture Handler

- (void)panGestureRecognized:(id)sender {
    // Initial Setup
    UICollectionView *scrollView = _collectionView;
    
    static float firstX, firstY;
    
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
        
//        _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        
        _isdraggingPhoto = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
    float newY = scrollView.center.y - viewHalfHeight;
    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    
    self.view.opaque = YES;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];;
    
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if(scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40) // Automatic Dismiss View
        {
            if (_senderViewForAnimation) {
                [self performDismissAnimation];
                return;
            }
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = [self.view frame].size.height;
            
            if(scrollView.center.y > viewHalfHeight+30) // swipe down
                finalY = windowsHeigt*2;
            else // swipe up
                finalY = -viewHalfHeight;
            
            CGFloat animationDuration = 0.35;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];
            [UIView commitAnimations];
            
            [self performSelector:@selector(back:) withObject:self afterDelay:animationDuration];
        }
        else // Continue Showing View
        {
            _isdraggingPhoto = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            
            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            [UIView commitAnimations];
        }
    }
}

#pragma mark - 设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    //    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    _indexBeforeRotation = _currentPage - 1;
}

- (void)setModels:(NSArray<JYAsset *> *)models
{
    _models = models;
    //如果预览网络图片则返回
    if (models.firstObject.type == JYAssetTypeNetImage) {
        return;
    }
}

- (void)initNavBtns
{
    
}

#pragma mark - 初始化CollectionView
- (void)initCollectionView
{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [_collectionView registerClass:[JYBigImgCell class] forCellWithReuseIdentifier:@"JYBigImgCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_collectionView];
}

- (void)initBottomView
{
    
}


- (void)handlerSingleTap
{
    _hideNavBar = !_hideNavBar;
    
    [self.navigationController setNavigationBarHidden:_hideNavBar animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:_hideNavBar withAnimation:UIStatusBarAnimationSlide];
    
    CGRect frame = _hideNavBar?CGRectMake(0, kViewHeight, kViewWidth, 44):CGRectMake(0, kViewHeight-44, kViewWidth, 44);
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.frame = frame;
    }];
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((JYBigImgCell *)cell).previewView resetScale];
    ((JYBigImgCell *)cell).willDisplaying = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((JYBigImgCell *)cell).previewView handlerEndDisplaying];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JYBigImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JYBigImgCell" forIndexPath:indexPath];
    JYAsset *model = self.models[indexPath.row];
    
    
    cell.showGif = YES;
    cell.showLivePhoto = YES;
    cell.model = model;
    weakify(self);
    cell.singleTapCallBack = ^() {
        strongify(weakSelf);
        [strongSelf handlerSingleTap];
    };
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == (UIScrollView *)_collectionView) {
        JYAsset *m = [self getCurrentPageModel];
        if (!m || [_modelIdentifile isEqualToString:m.asset.localIdentifier]) return;
        _modelIdentifile = m.asset.localIdentifier;
        //改变导航标题
        self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, self.models.count];
        if (m.type == JYAssetTypeGIF ||
            m.type == JYAssetTypeLivePhoto ||
            m.type == PHAssetMediaTypeVideo) {
            JYBigImgCell *cell = (JYBigImgCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
            [cell pausePlay];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    [self reloadCurrentCell];
}

- (void)reloadCurrentCell
{
    JYAsset *m = [self getCurrentPageModel];
    if (m.type == JYAssetTypeGIF ||
        m.type == JYAssetTypeLivePhoto) {
        JYBigImgCell *cell = (JYBigImgCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        [cell reloadGifLivePhoto];
    }
}

- (JYAsset *)getCurrentPageModel
{
    CGPoint offset = _collectionView.contentOffset;
    
    CGFloat page = offset.x/(kViewWidth+kItemMargin);
    if (ceilf(page) >= self.models.count) {
        return nil;
    }
    NSString *str = [NSString stringWithFormat:@"%.0f", page];
    _currentPage = str.integerValue + 1;
    JYAsset *model = self.models[_currentPage-1];
    return model;
}

- (CGRect)getCurrentPageRect
{
    CGRect frame;
    JYAsset * model = [self getCurrentPageModel];
    
    CGFloat w, h;
    if (model.asset) {
        w = [model.asset pixelWidth];
        h = [model.asset pixelHeight];
    } else if (model.image) {
        w = model.image.size.width;
        h = model.image.size.height;
    } else {
        w = kViewWidth;
        h = kViewHeight;
    }
    
    CGFloat width = MIN(kViewWidth, w);
    frame.origin = CGPointZero;
    frame.size.width = width;
    
    CGFloat imageScale = h/w;
    CGFloat screenScale = kViewHeight/kViewWidth;
    
    if (imageScale > screenScale) {
        frame.size.height = kViewHeight;
        frame.size.width = floorf(width * kViewHeight / h);
    } else {
        CGFloat height = floorf(width * imageScale);
        if (height < 1 || isnan(height)) {
            //iCloud图片height为NaN
            height = GetViewHeight(self.view);
        }
        frame.size.height = height;
    }
    frame.origin.x = (kViewWidth - frame.size.width)/2;
    frame.origin.y = (kViewHeight - frame.size.height)/2;
    
    return frame;
}

- (UIImage*)getImageFromView:(UIView *)view {
    if ([view isKindOfClass:[UIImageView class]]) {
        return ((UIImageView*)view).image;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    _collectionView.alpha = 0.0f;
    
    UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];

    CGRect senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];

    UIView *fadeView = [[UIView alloc] initWithFrame:self.view.bounds];
    fadeView.backgroundColor = [UIColor clearColor];
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    [mainWindow addSubview:fadeView];
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [mainWindow addSubview:resizableImageView];
    
//
//    //jy
//    //    _senderViewForAnimation.hidden = YES;
//    
    void (^completion)() = ^() {
        self.view.alpha = 1.0f;
        _collectionView.alpha = 1.0f;
        resizableImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
    };
    [UIView animateWithDuration:0.3 animations:^{
        fadeView.backgroundColor =  [UIColor blackColor];
    } completion:nil];
    
    CGRect finalImageViewFrame = [self getCurrentPageRect];
    self.view.opaque = YES;
    [UIView animateWithDuration:0.3 animations:^{
        resizableImageView.frame = finalImageViewFrame;
    } completion:^(BOOL finished) {
        completion();
    }];
}

- (void)performDismissAnimation
{
    float fadeAlpha = 1 - fabs(_collectionView.frame.origin.y)/_collectionView.frame.size.height;
    JYBigImgCell * cell = _collectionView.visibleCells[0];
    
    UIWindow * mainWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect rect = [cell.previewView convertRect:cell.previewView.imageViewFrame toView:self.view];

    UIImage * image = [self getImageFromView:_senderViewForAnimation];
    
    
    UIView *fadeView = [[UIView alloc] initWithFrame:mainWindow.bounds];
    fadeView.backgroundColor = [UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [mainWindow addSubview:fadeView];
    
    UIImageView *resizableImageView;
    
    resizableImageView  = [[UIImageView alloc] initWithImage:image];
    resizableImageView.frame = rect;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizableImageView.layer.masksToBounds = YES;
    [mainWindow addSubview:resizableImageView];
    self.view.hidden = YES;
    
    void (^completion)() = ^() {
        _senderViewForAnimation.hidden = NO;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
        // Gesture
        [mainWindow removeGestureRecognizer:_panGesture];
        // Controls
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    
    CGRect senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    [UIView animateWithDuration:0.4 animations:^{
        resizableImageView.frame = senderViewOriginalFrame;
        fadeView.alpha = 0;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        completion();
    }];
}

@end
