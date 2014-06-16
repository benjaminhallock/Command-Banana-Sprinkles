//
//  ViewController.m
//  MyFace Sandbox
//
//  Created by tbredemeier on 6/13/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "MainViewController.h"
#import "TopCollectionView.h"
#import "TopCollectionViewCell.h"
#import "MiddleCollectionView.h"
#import "MiddleCollectionViewCell.h"
#import "BottomCollectionView.h"
#import "BottomCollectionViewCell.h"

#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 410

@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet TopCollectionView *topCollectionView;
@property (strong, nonatomic) IBOutlet MiddleCollectionView *middleCollectionView;
@property (strong, nonatomic) IBOutlet BottomCollectionView *bottomCollectionView;
@property (strong, nonatomic) IBOutlet UILabel *winnerLabel;
@property NSMutableArray *splitPhotoArray;


@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSampleData];
    [self dupliateFirstAndLastElements];
    [self randomizeViews];
    [self becomeFirstResponder];
}

- (void)loadSampleData
{
    self.splitPhotoArray = [NSMutableArray array];
    [self.splitPhotoArray addObject:[self slicePhotos:[UIImage imageNamed:@"dog_PNG156"]]];
    [self.splitPhotoArray addObject:[self slicePhotos:[UIImage imageNamed:@"dog_PNG2442"]]];
    [self.splitPhotoArray addObject:[self slicePhotos:[UIImage imageNamed:@"dog_PNG2444"]]];

}

- (NSArray *)slicePhotos:(UIImage *)masterImage
{
    CGRect cropRect;
    CGImageRef imageRef;

    // first, resize image to fit height
    float vfactor = (masterImage.size.height / IMAGE_HEIGHT);

    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = masterImage.size.width / vfactor;
    float newHeight = masterImage.size.height / vfactor;

    CGSize scaleSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
    [masterImage drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // crop for the top image
    cropRect = CGRectMake(0, 0, newWidth * 2, 400);
    imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], cropRect);
    UIImage *image0 = [UIImage imageWithCGImage:imageRef];

    // crop for the middle image
    cropRect = CGRectMake(0, 400, newWidth * 2, 150);
    imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], cropRect);
    UIImage *image1 = [UIImage imageWithCGImage:imageRef];

    // crop for the bottom image
    cropRect = CGRectMake(0, 550, newWidth * 2, 270);
    imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], cropRect);
    UIImage *image2 = [UIImage imageWithCGImage:imageRef];

    return [NSArray arrayWithObjects:image0, image1, image2, nil];
}

- (void)dupliateFirstAndLastElements
{
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:[self.splitPhotoArray lastObject]];
    [temp addObjectsFromArray:self.splitPhotoArray];
    [temp addObject:[self.splitPhotoArray firstObject]];
    self.splitPhotoArray = temp;
}

- (void)randomizeViews
{
    NSUInteger index;
    do  // randomize at least once
    {
        // topCollectionView
        index = arc4random_uniform((int)(self.splitPhotoArray.count - 2)) + 1;
        [self scrollView:self.topCollectionView toIndex:index];

        // MiddleCollectionView
        index = arc4random_uniform((int)(self.splitPhotoArray.count - 2)) + 1;
        [self scrollView:self.middleCollectionView toIndex:index];

        // BottomCollectionView
        index = arc4random_uniform((int)(self.splitPhotoArray.count - 2)) + 1;
        [self scrollView:self.bottomCollectionView toIndex:index];

    } while ([self didWin]);    // if a random winner, randomize again
}

- (BOOL)didWin
{
    int topIndex = (int)((self.topCollectionView.contentOffset.x / self.topCollectionView.frame.size.width) + 0.5);
    int middleIndex = (int)((self.middleCollectionView.contentOffset.x / self.middleCollectionView.frame.size.width) + 0.5);
    int bottomIndex = (int)((self.bottomCollectionView.contentOffset.x / self.bottomCollectionView.frame.size.width) + 0.5);
    return topIndex == middleIndex && middleIndex == bottomIndex;
}

- (void)checkForWinner
{
    if([self didWin]) {
        self.winnerLabel.text = @"Winner!";
    self.view.backgroundColor = [UIColor whiteColor];
}
else {
        self.winnerLabel.text = @"";
    self.view.backgroundColor = [UIColor grayColor];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self randomizeViews];
        [self checkForWinner];
    }
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section
{
   return [self.splitPhotoArray count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *photo = [self.splitPhotoArray objectAtIndex:indexPath.row];

    if (collectionView == self.topCollectionView)
    {
        TopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TopCellID" forIndexPath:indexPath];
        cell.imageView.image = [photo objectAtIndex:0];
        return cell;
    }
    else if (collectionView == self.middleCollectionView)
    {
        MiddleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MiddleCellID" forIndexPath:indexPath];
        cell.imageView.image = [photo objectAtIndex:1];
        return cell;
    }
    else
    {
        BottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BottomCellID" forIndexPath:indexPath];
        cell.imageView.image = [photo objectAtIndex:2];
        return cell;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index;
    // Calculate where the collection view should be at the right-hand end item
    float contentOffsetWhenFullyScrolledRight = self.middleCollectionView.frame.size.width * ([self.splitPhotoArray count] -1);

    if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight)
    {
        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
        index = 1;
    }
    else if (scrollView.contentOffset.x == 0)
    {
        // user is scrolling to the left from the first item to the fake 'item N'.
        // reposition offset to show the 'real' item N at the right end end of the collection view
        index = [self.splitPhotoArray count] - 2;
    }
    else
    {
        [self checkForWinner];
        return;
    }

    if (scrollView == self.topCollectionView)
    {
        [self scrollView:self.topCollectionView toIndex:index];
    }
    else if (scrollView == self.middleCollectionView)
    {
        [self scrollView:self.middleCollectionView toIndex:index];
    }
    else
    {
        [self scrollView:self.bottomCollectionView toIndex:index];
    }
    [self checkForWinner];
}

- (void)scrollView:(UICollectionView *)collectionView toIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

@end
