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
#import "Resize.h"

@interface ChangeFaceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) IBOutlet UICollectionView *collectionView;
//@property NSArray *splitPhotoArray;
@end

@implementation ChangeFaceViewController {
    NSMutableArray *imageArray;
}

-(IBAction)onAddButtonPressed:(id)sender {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)viewDidLoad {
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    [self load];

    imageArray = [NSMutableArray new];

    for (Photos *hero in self.fetchedResultsController.fetchedObjects) {
        NSData *data = [NSData dataWithContentsOfFile:hero.imageURL];
        UIImage *image = [UIImage imageWithData:data];
        Resize *resizedImage = [Resize imageWithImage:image scaledToSize:CGSizeMake(32, 41)];
        [imageArray addObject:resizedImage];
    }

    UITapGestureRecognizer *doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    [doubleTapFolderGesture setNumberOfTapsRequired:2];
    [doubleTapFolderGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:doubleTapFolderGesture];
}

-(void)viewDidAppear:(BOOL)animated {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void) processDoubleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];

        if (indexPath)
        {
        Photos *selectedObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
            NSLog(@"Image was double tapped");
            [self.managedObjectContext deleteObject:selectedObject];
            [self.managedObjectContext save:nil];
            [self load];
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
    [self.collectionView reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photos *hero = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    ChangeFaceCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.imageView.image = imageArray[indexPath.row];
    if ([hero.selected  isEqual: @YES]) {
        cell.label.text = @"✔︎";
    } else {
        cell.label.text = @"";
    }
    cell.contentView.layer.shouldRasterize = YES;
    cell.contentView.layer.rasterizationScale = 2.0f;
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections.firstObject numberOfObjects];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Photos *hero = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    ChangeFaceCustomCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([hero.selected  isEqual: @YES]) {
        cell.label.text = @"";
        hero.selected  =@NO;
    } else {
        cell.label.text = @"✔︎"; //✪
        hero.selected = @YES;
    }
    [self.managedObjectContext save:nil];
}
@end
