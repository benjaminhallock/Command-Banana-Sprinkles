//
//  MakeFaceViewController.m
//  MyFace
//
//  Created by tbredemeier on 6/16/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "MakeFaceViewController.h"

@interface MakeFaceViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *makeFaceImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *makeFaceScrollView;

@end

@implementation MakeFaceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.makeFaceScrollView.contentSize = self.makeFaceImageView.frame.size;
    self.imagePicker.delegate = self;
    self.makeFaceScrollView.delegate = self;
    self.makeFaceScrollView.maximumZoomScale = 30;
    self.makeFaceScrollView.minimumZoomScale = 1;
    self.imagePicker.allowsEditing = NO;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.makeFaceImageView;
}

- (IBAction)onTakePhotoPressed:(id)sender
{
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}

-(UIImage*)captureFullScreen:(UIImageView *) targetView
{
    float scale = 1.0f/self.makeFaceScrollView.zoomScale;
    CGRect visibleRect;
    visibleRect.origin.x = self.makeFaceScrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.makeFaceScrollView.contentOffset.y * scale;
    visibleRect.size.width = self.makeFaceScrollView.bounds.size.width * scale;
    visibleRect.size.height = self.makeFaceScrollView.bounds.size.height * scale;
        CGImageRef cr = CGImageCreateWithImageInRect([targetView.image CGImage], visibleRect);
        UIImage* cropped = [[UIImage alloc] initWithCGImage:cr];
    UIImageWriteToSavedPhotosAlbum(cropped, nil, nil, nil);
        CGImageRelease(cr);
        return cropped;
    self.makeFaceImageView.image = nil;
}

- (IBAction)onUploadPhotoPressed:(id)sender
{
    if (self.makeFaceImageView.image == nil) {
[self presentViewController:self.imagePicker animated:YES completion:nil];
    } else {
    [self captureFullScreen:self.makeFaceImageView];
        self.makeFaceImageView.image = nil;
    }
}

#pragma mark - Image Picker Controller delegate methods
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // A photo was taken/selected!
    UIImage *imageTaken = [info objectForKey:UIImagePickerControllerOriginalImage];

    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // Save the image!
        UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil);
    }

    //You can take the metadata here => info [UIImagePickerControllerMediaMetadata];
    UIImage* imageCropped = [info objectForKey:UIImagePickerControllerEditedImage];

    CGFloat side = MIN(imageTaken.size.width, imageTaken.size.height);
    CGFloat x = imageTaken.size.width / 2 - side / 2;
    CGFloat y = imageTaken.size.height / 2 - side / 2;

    CGRect cropRect = CGRectMake(x,y,320, 410);
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageTaken CGImage], cropRect);
    UIImage *scaledOriginal = [UIImage imageWithCGImage:imageRef scale:imageCropped.scale orientation:imageTaken.imageOrientation];
    CGImageRelease(imageRef);

    self.makeFaceImageView.image = imageTaken;

    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


@end
