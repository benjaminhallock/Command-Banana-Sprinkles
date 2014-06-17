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
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property NSMutableArray *splitPhotoArray;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSampleData];
    [self dupliateFirstAndLastElements];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self randomizeViews];
}

- (void)loadSampleData
{
    self.splitPhotoArray = [NSMutableArray array];

    NSDictionary *photoItem;
    photoItem= @{@"name": @"Buster", @"photos":[self slicePhotos:[UIImage imageNamed:@"dog_PNG156"]]};
    [self.splitPhotoArray addObject:photoItem];
    photoItem = @{@"name": @"Fido", @"photos":[self slicePhotos:[UIImage imageNamed:@"dog_PNG2442"]]};
    [self.splitPhotoArray addObject:photoItem];
    photoItem = @{@"name": @"Max", @"photos":[self slicePhotos:[UIImage imageNamed:@"dog_PNG2444"]]};
    [self.splitPhotoArray addObject:photoItem];
}

// automatically split the photos into three horizontal sections
- (NSArray *)slicePhotos:(UIImage *)masterImage
{
    CGRect cropRect;
    CGImageRef imageRef;

    // first, determine vertical scaling factor
    float vfactor = (masterImage.size.height / IMAGE_HEIGHT);

    // divide the size by the vertical scaling factor
    float newWidth = masterImage.size.width / vfactor;
    float newHeight = masterImage.size.height / vfactor;

    // scale the image to fit vertically
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

    // finally return the three (sliced) images
    return [NSArray arrayWithObjects:image0, image1, image2, nil];
}

// to enable the illusion of a circular array of photos
- (void)dupliateFirstAndLastElements
{
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:[self.splitPhotoArray lastObject]];
    [temp addObjectsFromArray:self.splitPhotoArray];
    [temp addObject:[self.splitPhotoArray firstObject]];
    self.splitPhotoArray = temp;
}

// show (animate) the random shuffling of sliced images
- (void)randomizeViews
{
    NSUInteger index;
    // topCollectionView
    index = arc4random_uniform((int)(self.splitPhotoArray.count - 2)) + 1;
    [self scrollView:self.topCollectionView toIndex:index animated:YES];

    // MiddleCollectionView
    index = arc4random_uniform((int)(self.splitPhotoArray.count - 2)) + 1;
    [self scrollView:self.middleCollectionView toIndex:index animated:YES];

    // BottomCollectionView
    index = arc4random_uniform((int)(self.splitPhotoArray.count - 2)) + 1;
    [self scrollView:self.bottomCollectionView toIndex:index animated:YES];
}

// check if a match has occured, and if so, display the photo name
- (void)checkForWinner
{
    if([self didWin])
    {
        self.view.backgroundColor = [UIColor whiteColor];
        NSDictionary *photo = [self.splitPhotoArray objectAtIndex:[self displayedPhotoIndex:self.topCollectionView]];
        NSString *name = [photo objectForKey:@"name"];
        self.nameLabel.text = name;
    }
    else
    {
        self.view.backgroundColor = [UIColor grayColor];
        self.nameLabel.text = @"";
    }
}

// determine if a photo is properly alligned
- (BOOL)didWin
{
    NSInteger topIndex = [self displayedPhotoIndex:self.topCollectionView];
    NSInteger middleIndex = [self displayedPhotoIndex:self.middleCollectionView];
    NSInteger bottomIndex = [self displayedPhotoIndex:self.bottomCollectionView];

    return topIndex == middleIndex && middleIndex == bottomIndex;
}

// helper method to return the array index position of the given sliced photo
- (NSInteger)displayedPhotoIndex:(UICollectionView *)collectionView
{
    return (int)((collectionView.contentOffset.x / collectionView.frame.size.width) + 0.5);
}

// shake gesture event handler that will then reshuffle photos
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self randomizeViews];
        [self checkForWinner];
    }
}

# pragma mark - collection view delegate methods

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
    NSDictionary *photoItem = [self.splitPhotoArray objectAtIndex:indexPath.row];
    NSArray *photos = [photoItem objectForKey:@"photos"];

    if (collectionView == self.topCollectionView)
    {
        TopCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TopCellID" forIndexPath:indexPath];
        cell.imageView.image = [photos objectAtIndex:0];
        return cell;
    }
    else if (collectionView == self.middleCollectionView)
    {
        MiddleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MiddleCellID" forIndexPath:indexPath];
        cell.imageView.image = [photos objectAtIndex:1];
        return cell;
    }
    else
    {
        BottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BottomCellID" forIndexPath:indexPath];
        cell.imageView.image = [photos objectAtIndex:2];
        return cell;
    }
}

#pragma mark - scroll control methods

// used to provide the impression of an infinite circular collection of photos
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
        [self scrollView:self.topCollectionView toIndex:index animated:NO];
    }
    else if (scrollView == self.middleCollectionView)
    {
        [self scrollView:self.middleCollectionView toIndex:index animated:NO];
    }
    else
    {
        [self scrollView:self.bottomCollectionView toIndex:index animated:NO];
    }
    [self checkForWinner];
}

// helper method to scroll the given sliced photo to a new position
- (void)scrollView:(UICollectionView *)collectionView toIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}

@end
