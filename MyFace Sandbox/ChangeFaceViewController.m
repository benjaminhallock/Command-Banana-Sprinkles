//
//  ChangeFaceViewController.m
//  MyFace
//
//  Created by benjaminhallock@gmail.com on 6/16/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "ChangeFaceViewController.h"
#import "ChangeFaceCustomCell.h"
#import "Photos.h"
#import "AppDelegate.h"

@interface ChangeFaceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//@property NSArray *splitPhotoArray;
@end

@implementation ChangeFaceViewController

-(void)viewDidLoad {

    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    [self load];
}

-(void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@passenger ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
    [self.fetchedResultsController performFetch:nil];
    [self.collectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [self load];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    Photos *hero = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ChangeFaceCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithData:hero.image];
    
    if ([hero.selected  isEqual: @YES]) {
        cell.label.text = @"✪";
    } else {
        cell.label.text = @"";
    }
    return cell;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections.firstObject numberOfObjects];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Photos *hero = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ChangeFaceCustomCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([hero.selected  isEqual: @YES]) {
        cell.label.text = @"";
        hero.selected  =@NO;
    } else {
        cell.label.text = @"✪";
        hero.selected = @YES;
    }
    [self.managedObjectContext save:nil];
}
@end
