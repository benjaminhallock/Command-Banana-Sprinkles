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

    UITapGestureRecognizer *doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    [doubleTapFolderGesture setNumberOfTapsRequired:2];
    [doubleTapFolderGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:doubleTapFolderGesture];
}

- (void) processDoubleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        Photos *selectedObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        if (indexPath)
        {
            NSLog(@"Image was double tapped");
            [self.managedObjectContext deleteObject:selectedObject];
            [self.managedObjectContext save:nil];
            [self viewDidAppear:YES];
        }
        else
        {

        }
    }
}

-(void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@passenger ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
    [self.fetchedResultsController performFetch:nil];
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, 320, 30)];
        label.text = @"Need 3 photos";
        label.font = [UIFont fontWithName:@"Heiti SC" size:30];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        [self.view addSubview:label];
    }
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
