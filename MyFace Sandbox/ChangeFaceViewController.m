

#import "ChangeFaceViewController.h"
#import "ChangeFaceCustomCell.h"
#import "Photos.h"
#import "AppDelegate.h"
#import "Resize.h"

#import <AudioToolbox/AudioToolbox.h>

@interface ChangeFaceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property CGPoint savedPoint;
@property UITapGestureRecognizer *tapGestureRecognizer;
@property BOOL didViewJustLoad;

@end

@implementation ChangeFaceViewController
{
    NSMutableArray *imageArray;
}

-(IBAction)didPressCameraRoll:(id)sender
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.imagePicker animated:YES completion:^
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

-(void)viewDidLoad
{
    self.didViewJustLoad = YES;

    self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;

    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    [self load];

    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    //    doubleTapFolderGesture.minimumPressDuration = (CFTimeInterval)1.0;
    [self.view addGestureRecognizer:longpress];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    if (!self.didViewJustLoad)
    {
        [self load];
    }
    else
    {
        self.didViewJustLoad = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
}

//Long press to Delete
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (!self.editing)
    {
        CGPoint cellpoint = [sender locationInView:self.collectionView];
        NSLog(@"%@ pointhold", NSStringFromCGPoint(cellpoint));
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:cellpoint];
        if (indexPath)
        {
            if (sender.state == UIGestureRecognizerStateBegan)
        {
            [self startWobble];
            AudioServicesPlaySystemSound (1104);
            self.editing = YES;
        }
        }
    }
}

//Tap to Delete if Editing
- (void)didTapGesture:(UITapGestureRecognizer *)sender
{
    if (self.editing)
    {
        CGPoint point = [self.tapGestureRecognizer locationInView:self.collectionView];
        NSLog(@"%@ pointtap", NSStringFromCGPoint(point));
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];

        if (indexPath)
        {
            Photos *selectedObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
            [self.managedObjectContext deleteObject:selectedObject];
            AudioServicesPlaySystemSound (1109);

            //Orange Flash
            [UIView animateWithDuration:1.0f animations:^{

                UIColor *savedColor = self.collectionView.backgroundColor;
                self.collectionView.backgroundColor = [[UIColor alloc] initWithRed:244/255.0f green:120/255.0f blue:58/255.0f alpha:1.0f];

                self.collectionView.backgroundColor = savedColor;
            }];
        
            [self.managedObjectContext save:nil];

            [self load];
        }
        [self stopWobble];
    }
}

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
static float angle = 0.035;
static float offset = 0;
static float transform = -0.5;

- (void)startWobble
{
    for (UICollectionViewCell *itemView in self.collectionView.subviews)
    {
        UILabel *button = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 64, 82)];
//        button.titleLabel.textColor  = [UIColor blackColor];
//        button.titleLabel.text = @"✗";
//        [button setTitle: @"✗" forState: UIControlStateApplication];
        button.font = [UIFont fontWithName:@"Helvetica" size:50];
        button.textAlignment = NSTextAlignmentCenter;
        button.text =@"✗";
        button.textColor = [UIColor blackColor];
        button.backgroundColor = [UIColor whiteColor];
        button.alpha = .8;
        button.layer.cornerRadius = 15;
        button.layer.rasterizationScale = 1.0f;
        button.userInteractionEnabled = NO;
        button.layer.borderColor = [UIColor orangeColor].CGColor;
        button.layer.masksToBounds = YES;
        button.enabled = NO;

        //        [button addTarget:self
        //                   action:@selector(didTapGesture:)
        //         forControlEvents:UIControlEventTouchUpInside];

        button.layer.borderWidth = 2;
        [itemView insertSubview:button aboveSubview:itemView.subviews.firstObject];

        //Start Max Wiggle

        itemView.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1.0);

        angle = -angle;

        offset += 0.03;
        if (offset > 0.9)
            offset -= 0.9;

        transform = -transform;

        CABasicAnimation *aa = [CABasicAnimation animationWithKeyPath:@"transform"];
        aa.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle, 0, 0, 1.0)];
        aa.repeatCount = HUGE_VALF;
        aa.duration = 0.12;
        aa.autoreverses = YES;
        aa.timeOffset = offset;
        [itemView.layer addAnimation:aa forKey:nil];

        aa = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        aa.duration = 0.08;
        aa.repeatCount = HUGE_VALF;
        aa.autoreverses = YES;
        aa.fromValue = @(transform);
        aa.toValue = @(-transform);
        aa.fillMode = kCAFillModeForwards;
        aa.timeOffset = offset;
        [itemView.layer addAnimation:aa forKey:nil];

        aa = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        aa.duration = 0.09;
        aa.repeatCount = HUGE_VALF;
        aa.autoreverses = YES;
        aa.fromValue = @(transform);
        aa.toValue = @(-transform);
        aa.fillMode = kCAFillModeForwards;
        aa.timeOffset = offset + 0.6;
        [itemView.layer addAnimation:aa forKey:nil];
    }

    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapGesture:)];
    self.tapGestureRecognizer.delegate = self;
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}


- (void)stopWobble
{
    if (self.editing)
    {
        for (UICollectionViewCell *itemView in self.collectionView.subviews)
        {
            [itemView.layer removeAllAnimations];
            itemView.layer.transform = CATransform3DIdentity;
            [itemView.subviews.lastObject removeFromSuperview];
        }
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
        self.editing = NO;
    }
}

#warning Push the data from the previous controller
-(void)load
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//  NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@passenger ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
    [self.fetchedResultsController performFetch:0];

    imageArray = [NSMutableArray new];

    for (Photos *facePhoto in self.fetchedResultsController.fetchedObjects)
    {
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",facePhoto.imageURL]];
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        UIImage *image = [UIImage imageWithData:data];
        UIImage *resizedImage = [Resize imageWithImage:image scaledToSize:CGSizeMake(32, 41)];
        [imageArray addObject:resizedImage];
    }

    [self.collectionView reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photos *facePhoto = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    ChangeFaceCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    cell.imageView.image = imageArray[indexPath.row];
    if ([facePhoto.selected  isEqual: @YES]) {
        cell.label.text = @"✔︎";
    } else {
        cell.label.text = @"";
    }
    cell.contentView.layer.shouldRasterize = YES;
    cell.contentView.layer.rasterizationScale = 2.0f;
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.sections.firstObject numberOfObjects];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photos *hero = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    ChangeFaceCustomCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    if ([hero.selected  isEqual: @YES])
    {
        cell.label.text = @"";
        hero.selected  =@NO;
        AudioServicesPlaySystemSound (1103);
    }
    else
    {
        cell.label.text = @"✔︎"; //✪
        AudioServicesPlaySystemSound (1103);
        hero.selected = @YES;
    }
    [self.managedObjectContext save:nil];
}

@end
