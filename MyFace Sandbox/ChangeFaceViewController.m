//
//  ChangeFaceViewController.m
//  MyFace
//
//  Created by benjaminhallock@gmail.com on 6/16/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "ChangeFaceViewController.h"

@interface ChangeFaceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation ChangeFaceViewController

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 50;
}
@end
