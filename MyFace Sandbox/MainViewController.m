
#import "MainViewController.h"
#import "TopCollectionView.h"
#import "TopCollectionViewCell.h"
#import "MiddleCollectionView.h"
#import "MiddleCollectionViewCell.h"
#import "BottomCollectionView.h"
#import "BottomCollectionViewCell.h"
#import "AppDelegate.h"
#import "Photos.h"
#import "ChangeFaceViewController.h"
#import "Resize.h"

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 410

@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet TopCollectionView *topCollectionView;
@property (weak, nonatomic) IBOutlet MiddleCollectionView *middleCollectionView;
@property (weak, nonatomic) IBOutlet BottomCollectionView *bottomCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *buttonShuffle;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property NSMutableArray *splitPhotoArray;
@end

@implementation MainViewController {
    SystemSoundID arrows;
}

- (void)viewDidLoad
{
    //    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logowhite"]];
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [self loadImagePicker];
    [self ViewDidLoadAnimation];

        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(processLongPress:)];
        [self.view addGestureRecognizer:longpress];
}

//Take a Screenshot by holding screen.
-(void)processLongPress:(UILongPressGestureRecognizer *)sender {
    self.editing = !self.editing;
    if (self.editing) {
        [self onScreenShotTook:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(IBAction)unwind:(UIStoryboardSegue *)sender
{

}

- (void)viewDidAppear:(BOOL)animated
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 75, 320, 410)];
        image.image = [UIImage imageNamed:@"template"];
        self.imagePicker.cameraOverlayView = image;
        self.imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;

    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self load];
    [self duplicateFirstAndLastElements];
    [self randomizeViews];
}

//Press to hold and take a screenshot.
- (IBAction)onScreenShotTook:(id)sender
{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 430), NO, 0.0);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    [data writeToFile:[NSString stringWithFormat:@"%i", arc4random_uniform(100)] atomically:NO];
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], 0, 0, 0);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Saved to Roll" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];

    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0f];

    AudioServicesPlaySystemSound (1108);

    //Not Used Because of Kids Sharing Limitation.
    //    NSArray *activityItems = [NSArray arrayWithObjects:@"You should totallly try the best app in the world, myFace",[UIImage imageWithData:data], nil];
    //    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    //    [self presentViewController:activityController animated:YES completion:nil];
}

-(void)dismiss:(UIAlertView *)alert {
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

-(IBAction)onCameraButtonPressed:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraChanged:)
                                                 name:@"AVCaptureDeviceDidStartRunningNotification"
                                               object:nil];
}

- (void)cameraChanged:(NSNotification *)notification
{
    if(_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        _imagePicker.cameraViewTransform = CGAffineTransformIdentity;
        _imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, -1,     1);
    } else {
        _imagePicker.cameraViewTransform = CGAffineTransformIdentity;
    }
}

-(IBAction)shuffleButton:(id)sender {
    [self randomizeViews];
    AudioServicesPlaySystemSound (1105);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChangeFaceViewController *nextView = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"showGallery"]) {
        nextView.imagePicker = self.imagePicker;
        nextView.imageEditor = self.imageEditor;
        nextView.library = self.library;
    }
}

-(void)ViewDidLoadAnimation
{
    self.buttonShuffle.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        self.nameLabel.alpha = 0;
        self.nameLabel.alpha = 1;
    }];

    [UIView animateWithDuration:0.5 animations:^{
        self.nameLabel.frame = CGRectMake(0, 0, 320, self.nameLabel.frame.size.height);
        self.nameLabel.frame = CGRectMake(0, 0, 320, 30);
    }];
    [UIView animateWithDuration:1.0 delay:2.0 options:0 animations:^{
        self.nameLabel.alpha = 1;
        self.nameLabel.alpha = 0;
        self.buttonShuffle.alpha = 0;
        self.buttonShuffle.alpha = 1;
    } completion:nil];

    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(randomizeViews)
                                   userInfo:nil
                                    repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0f
                                     target:self
                                   selector:@selector(randomizeViews)
                                   userInfo:nil
                                    repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(randomizeViews)
                                   userInfo:nil
                                    repeats:NO];

}

-(void)loadImagePicker {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.delegate = self;
    self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext; //fixes snapshot error

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 75, 320, 410)];
        image.image = [UIImage imageNamed:@"template"];
        self.imagePicker.cameraOverlayView = image;
    }
    else
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    self.imageEditor = [storyboard instantiateViewControllerWithIdentifier:@"DemoImageEditor"];
    self.imageEditor.checkBounds = YES;
    self.imageEditor.rotateEnabled = YES;
    self.imageEditor.modalPresentationStyle = UIModalPresentationCurrentContext;//Seing if this helps
    self.library = library;

    self.imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        if(!canceled && editedImage) {
            //[library writeImageToSavedPhotosAlbum:[editedImage CGImage]
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
            NSString *path = [self writeImage:editedImage withName:@"gallery"];
            [newManagedObject setValue:path forKey:@"imageURL"];
            [newManagedObject setValue:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"name"];
            [newManagedObject setValue:@YES forKey:@"selected"];
            [self.managedObjectContext save:nil];
        }
    };
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];

    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (image != nil) {
            Resize *resizedImage = [Resize imageWithImage:image scaledToSize:CGSizeMake(320, 410)];
            UIImageWriteToSavedPhotosAlbum(resizedImage, 0, 0, 0);
            UIImage *finalImage = resizedImage;
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];

            NSString *path = [self writeImage:finalImage withName:@"camera"];
            [newManagedObject setValue:path forKey:@"imageURL"];
            [newManagedObject setValue:@"Zeus" forKey:@"name"];
            [newManagedObject setValue:@YES forKey:@"selected"];
            [self.managedObjectContext save:nil];
        }
    }
    else
    {
        [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            UIImage *preview = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
            self.imageEditor.sourceImage = image;
            self.imageEditor.previewImage = preview;
            [self.imageEditor reset:NO];
            [picker pushViewController:self.imageEditor animated:YES];
            [picker setNavigationBarHidden:YES animated:NO];

        } failureBlock:^(NSError *error) {
            NSLog(@"Failed to get asset from library");
        }];
    }
}

-(NSString *) writeImage:(UIImage *)image withName:(NSString *)name {
    NSString *fileName = [NSString stringWithFormat:@"%@%u.png",name,arc4random_uniform(1000000)];

    NSString *applicationDocumentsDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:fileName];
//    NSLog(@"%@", applicationDocumentsDir);
    //  NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [UIImagePNGRepresentation(image) writeToFile:applicationDocumentsDir atomically:YES];
    return fileName;
}

// Not used in this case
- (NSData *) getImageFromURL:(NSString *)fileURL
{
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    NSData *resultt = UIImagePNGRepresentation(result);
    return resultt;
}

//Fetch Core Data and Reload if empty
- (void)load {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];
    request.predicate = [NSPredicate predicateWithFormat:@"selected > 0"];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
    [self.fetchedResultsController performFetch:0];

    //////////////////////////////////////////////////////////////
    if (self.fetchedResultsController.fetchedObjects.count  < 3) {
        NSLog(@"less than 3 fetched");
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Photos"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObjects:sort,nil];
        //      request.predicate = [NSPredicate predicateWithFormat:@"selected > 0"];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Cache"];
        [self.fetchedResultsController performFetch:nil];

        for (NSManagedObject *face in self.fetchedResultsController.fetchedObjects) {
            [self.managedObjectContext deleteObject:face];
            [self.managedObjectContext save:nil];
        }

        self.splitPhotoArray = [NSMutableArray array];
        NSDictionary *photoItem;

        photoItem = @{@"name":@"Frank" ,@"photos":[UIImage imageNamed:@"sample1"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Tom" ,@"photos":[UIImage imageNamed:@"sample2"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Brian" ,@"photos":[UIImage imageNamed:@"sample3"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Sally" ,@"photos":[UIImage imageNamed:@"sample4"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Ben" ,@"photos":[UIImage imageNamed:@"wsample5"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Don" ,@"photos":[UIImage imageNamed:@"sample7"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Tim" ,@"photos":[UIImage imageNamed:@"sample8"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Frank1" ,@"photos":[UIImage imageNamed:@"wsample9"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Tom1" ,@"photos":[UIImage imageNamed:@"sample10"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Brian1" ,@"photos":[UIImage imageNamed:@"wsample11"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Sally1" ,@"photos":[UIImage imageNamed:@"wsample12"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Ben1" ,@"photos":[UIImage imageNamed:@"sample13"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Max1" ,@"photos":[UIImage imageNamed:@"wsample14"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Don1" ,@"photos":[UIImage imageNamed:@"wsample15"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Tim1" ,@"photos":[UIImage imageNamed:@"sample16"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Tom1" ,@"photos":[UIImage imageNamed:@"sample17"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Brian2" ,@"photos":[UIImage imageNamed:@"sample18"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Sally2" ,@"photos":[UIImage imageNamed:@"wsample19"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Ben2" ,@"photos":[UIImage imageNamed:@"sample20"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Max2" ,@"photos":[UIImage imageNamed:@"wsample21"]};
        [self.splitPhotoArray addObject:photoItem];
        photoItem = @{@"name":@"Don2" ,@"photos":[UIImage imageNamed:@"wsample22"]};
        [self.splitPhotoArray addObject:photoItem];

        for (NSDictionary *person in self.splitPhotoArray) {
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
            NSString *path = [self writeImage:person[@"photos"] withName:@"stock"];
            [newManagedObject setValue:path forKey:@"imageURL"];
            [newManagedObject setValue:person[@"name"] forKey:@"name"];
            [newManagedObject setValue:@YES forKey:@"selected"];
            [self.managedObjectContext save:nil];
        }
        [self load]; //should have more than 3 now.
    } // End if less than 3 selected images;

    self.splitPhotoArray = [NSMutableArray new];

    for (Photos *face in self.fetchedResultsController.fetchedObjects)
    {
//        NSLog(@"%@", face.imageURL);
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",face.imageURL]];
//        NSLog(@"%@",fullPath);
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        UIImage *image = [UIImage imageWithData:data];
        NSArray *photos = [NSArray new];
        photos = [self slicePhotos:image];
        NSDictionary *photoItem = @{@"name":face.name , @"photos":photos};
//        NSLog(@"%@",photoItem);
        [self.splitPhotoArray addObject:photoItem];
    }

    [self.bottomCollectionView reloadData];
    [self.topCollectionView reloadData];
    [self.middleCollectionView reloadData];

}

// automatically split the photos into three horizontal sections
- (NSArray *)slicePhotos:(UIImage *)masterImage
{
    NSLog(@"slicing");
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
    NSArray *array = [NSArray arrayWithObjects:image0, image1, image2, nil];
    NSLog(@"%@", array);
    return array;
}

// to enable the illusion of a circular array of photos
- (void)duplicateFirstAndLastElements
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
    // topCollectionView
    NSUInteger index = arc4random_uniform(self.splitPhotoArray.count);
    NSUInteger index1 = arc4random_uniform(self.splitPhotoArray.count);
    NSUInteger index2 = arc4random_uniform(self.splitPhotoArray.count);
    [self scrollView:self.topCollectionView toIndex:index animated:YES];
    [self scrollView:self.middleCollectionView toIndex:index1 animated:YES];
    [self scrollView:self.bottomCollectionView toIndex:index2 animated:YES];
}

// check if a match has occured, and if so, display the photo name
- (void)checkForWinner
{
    if([self didWin])
    {
        self.topCollectionView.scrollEnabled = NO;
        self.middleCollectionView.scrollEnabled = NO;
        self.bottomCollectionView.scrollEnabled = NO;

        //        AudioServicesPlaySystemSound (1028);
        AudioServicesPlaySystemSound (1332);
        //         AudioServicesPlaySystemSound (1331);

        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
        view.alpha = 0;
        view.backgroundColor = [UIColor whiteColor];
        [self.view insertSubview:view aboveSubview:self.view];
        //        NSDictionary *photo = [self.splitPhotoArray objectAtIndex:[self displayedPhotoIndex:self.topCollectionView]];
        //        NSString *name = [photo objectForKey:@"name"];
        //        self.nameLabel.text = name;
        //        self.nameLabel.alpha = 0;
        [UIView animateWithDuration:1.0f animations:^{
            view.alpha = .5;
            view.alpha = 0;
            self.view.backgroundColor = [[UIColor alloc] initWithRed:244/255.0f green:120/255.0f blue:58/255.0f alpha:1.0f];
            self.view.backgroundColor = [[UIColor alloc] initWithRed:0/255.0f green:169/255.0f blue:162/255.0f alpha:1.0f];
            //            self.nameLabel.alpha = 0;
            //            self.nameLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [self performSelector:@selector(randomizeViews) withObject:self afterDelay:2.0f];
                self.topCollectionView.scrollEnabled = 1;
                self.middleCollectionView.scrollEnabled = 1;
                self.bottomCollectionView.scrollEnabled = 1;
            }
        }];
        //
        //        [UIView animateWithDuration:2.0 delay:1.0 options:0 animations:^{
        //
        //            //            self.nameLabel.alpha = 1;
        //            //            self.nameLabel.alpha = 0;
        //        } completion:nil];
    } else {
        //You don't WIN
        AudioServicesPlaySystemSound (1103);
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
        cell.imageView.image = photos[0];
        return cell;
    }
    else if (collectionView == self.middleCollectionView)
    {
        MiddleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MiddleCellID" forIndexPath:indexPath];
        cell.imageView.image = photos[1];
        return cell;
    }
    else
    {
        BottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BottomCellID" forIndexPath:indexPath];
        cell.imageView.image = photos[2];
        return cell;
    }
}

#pragma mark - scroll control methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self infiniteScroll:scrollView];

    if (!self.topCollectionView.pagingEnabled) {
        [self.topCollectionView scrollToItemAtIndexPath:[self.topCollectionView indexPathsForVisibleItems].firstObject atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }

    [self checkForWinner];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self infiniteScroll:scrollView];
}

// used to provide the impression of an infinite circular collection of photos
- (void)infiniteScroll:(UIScrollView *)scrollView
{
    NSInteger index;
    NSInteger frameWidth = self.middleCollectionView.frame.size.width;

    // Calculate where the collection view should be at the right-hand end item
    float contentOffsetWhenFullyScrolledRight = frameWidth * ([self.splitPhotoArray count] -1);

    if (abs(scrollView.contentOffset.x - contentOffsetWhenFullyScrolledRight) < frameWidth / 3)    {
        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
        index = 1;
    }
    else if (abs(scrollView.contentOffset.x) < frameWidth / 3)
    {
        // user is scrolling to the left from the first item to the fake 'item N'.
        // reposition offset to show the 'real' item N at the right end end of the collection view
        index = [self.splitPhotoArray count] - 2;
    }
    else
    {
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
}


// helper method to scroll the given sliced photo to a new position
- (void)scrollView:(UICollectionView *)collectionView toIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
}

@end
