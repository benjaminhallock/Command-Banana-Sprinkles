//
//  ChangeFaceViewController.m
//  MyFace
//
//  Created by benjaminhallock@gmail.com on 6/16/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "ChangeFaceViewController.h"
#import "ChangeFaceCustomCell.h"

@interface ChangeFaceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property NSArray *splitPhotoArray;

@end

@implementation ChangeFaceViewController

-(void)viewDidLoad {
    UIImage *image0 = [UIImage imageNamed:@"dog_PNG156"];
    UIImage *image1 = [UIImage imageNamed:@"dog_PNG2442"];
    UIImage *image2 = [UIImage imageNamed:@"dog_PNG2444"];
    self.splitPhotoArray = [NSArray new];
    self.splitPhotoArray = @[image0, image1, image2];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChangeFaceCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = [self.splitPhotoArray objectAtIndex:arc4random_uniform(3)];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arc4random_uniform(20);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ChangeFaceCustomCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell.label.text isEqualToString:@"✪"]) {
        cell.label.text = @"";
    } else {
    cell.label.text = @"✪";
    }
}
@end
