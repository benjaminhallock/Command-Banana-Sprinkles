

#import "ChangeFaceViewController.h"
#import "ChangeFaceCustomCell.h"
#import "Photos.h"
#import "AppDelegate.h"
#import "Resize.h"

@interface ChangeFaceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property CGPoint savedPoint;
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

    UILongPressGestureRecognizer *doubleTapFolderGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
//    [doubleTapFolderGesture setNumberOfTapsRequired:2];
//    doubleTapFolderGesture.minimumPressDuration = (CFTimeInterval)1.0;
//    [doubleTapFolderGesture setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:doubleTapFolderGesture];
}

-(void)viewWillAppear:(BOOL)animated {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}
-(void)viewDidAppear:(BOOL)animated {
    [self load];
}

- (void)processDoubleTap:(UILongPressGestureRecognizer *)sender
{
    self.savedPoint = [sender locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:self.savedPoint];
    if (indexPath)
    {
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.editing = YES;
        if (self.editing) {
            [self startWobble];
        } else {
            [self stopWobble];
        }
    }
    }
}

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

- (void)startWobble {
    for (UICollectionViewCell *itemView in self.collectionView.subviews) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(-3, -3, 30, 30)];
        button.titleLabel.textColor  = [UIColor whiteColor];
        button.titleLabel.text = @"✗";
//        button.titleLabel.font = [UIFont fontWithName:@"Arial" size:5];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.backgroundColor = [UIColor blackColor];
        button.titleLabel.tintColor = [UIColor whiteColor];
        button.layer.cornerRadius = 15;
        button.layer.borderColor = [UIColor orangeColor].CGColor;
        button.layer.masksToBounds = YES;
        [button addTarget:self
                   action:@selector(stopWobble)
         forControlEvents:UIControlEventTouchUpInside];
        button.layer.borderWidth = 2;
        [itemView insertSubview:button aboveSubview:itemView.subviews.firstObject];

    itemView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-5));
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
                         itemView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(5));
                     }
                     completion:NULL
     ];
    }
    
}

- (void)stopWobble {
    if (self.editing) {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:self.savedPoint];
              if (indexPath)
                {
                Photos *selectedObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
                    [self.managedObjectContext deleteObject:selectedObject];
                    [self.managedObjectContext save:nil];
                    [self load];
                }
    for (UICollectionViewCell *itemView in self.collectionView.subviews) {
        [itemView.subviews.lastObject removeFromSuperview];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         itemView.transform = CGAffineTransformIdentity;
                     }
                     completion:NULL
     ];
    }
        self.editing = NO;
}
}

-(void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@passenger ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
    [self.fetchedResultsController performFetch:nil];

    imageArray = [NSMutableArray new];

    for (Photos *hero in self.fetchedResultsController.fetchedObjects) {
        NSData *data = [NSData dataWithContentsOfFile:hero.imageURL];
        UIImage *image = [UIImage imageWithData:data];
        Resize *resizedImage = [Resize imageWithImage:image scaledToSize:CGSizeMake(32, 41)];
        [imageArray addObject:resizedImage];
    }

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
