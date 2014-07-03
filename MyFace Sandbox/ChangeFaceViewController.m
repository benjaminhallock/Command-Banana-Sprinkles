

#import "ChangeFaceViewController.h"
#import "ChangeFaceCustomCell.h"
#import "Photos.h"
#import "AppDelegate.h"
#import "Resize.h"

@interface ChangeFaceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property CGPoint savedPoint;
@property UITapGestureRecognizer *tapGestureRecognizer;
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
//    doubleTapFolderGesture.minimumPressDuration = (CFTimeInterval)1.0;
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
    CGPoint cheese = [sender locationInView:self.collectionView];
    NSLog(@"%@ pointhold", NSStringFromCGPoint(cheese));
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:cheese];
    if (indexPath)
    {
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.editing = YES;
        if (self.editing) {
            [self startWobble];
        }
    }
    }
}

-(void)didTapGesture:(UITapGestureRecognizer *)sender {
    if (self.editing) {
        CGPoint point = [self.tapGestureRecognizer locationInView:self.collectionView];
        NSLog(@"%@ pointtap", NSStringFromCGPoint(point));
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if (indexPath) {
                Photos *selectedObject = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
                [self.managedObjectContext deleteObject:selectedObject];
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

- (void)startWobble {
    for (UICollectionViewCell *itemView in self.collectionView.subviews) {
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


- (void)stopWobble {
    if (self.editing) {
    for (UICollectionViewCell *itemView in self.collectionView.subviews) {
        [itemView.layer removeAllAnimations];
        itemView.layer.transform = CATransform3DIdentity;
        [itemView.subviews.lastObject removeFromSuperview];
    }
        self.editing = NO;
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
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
