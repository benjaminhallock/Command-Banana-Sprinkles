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
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFace;
@property (weak, nonatomic) IBOutlet UIScrollView *makeFaceScrollView;
@property DemoImageEditor *imageEditor;
@property(nonatomic,strong) ALAssetsLibrary *library;
@end

@implementation MakeFaceViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageViewFace.hidden = YES;
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    //    self.makeFaceScrollView.delegate = self; // In storyboard
    self.makeFaceScrollView.contentSize = self.makeFaceImageView.frame.size;
    self.makeFaceScrollView.maximumZoomScale = 25;
    self.makeFaceScrollView.minimumZoomScale = 0;
    self.imagePicker.allowsEditing = NO;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
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
    self.library = library;

    self.imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        if(!canceled) {
            [library writeImageToSavedPhotosAlbum:[editedImage CGImage]

                                      orientation:(ALAssetOrientation)editedImage.imageOrientation
                                  completionBlock:^(NSURL *assetURL, NSError *error){
                                      if (error) {
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Saving"
                                                                                          message:[error localizedDescription]
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Ok"
                                                                                otherButtonTitles: nil];
                                          [alert show];
                                      }
                                  }];
            }
    };
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.makeFaceImageView;
}

- (IBAction)onTakePhotoPressed:(UIButton *)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    self.imageViewFace.hidden = NO;
}

- (IBAction)onUploadPhotoPressed:(id)sender
{
    //Save to core data;
    self.makeFaceImageView.image = nil;
    self.imageViewFace.hidden = YES;
}


#pragma mark - Image Picker Controller delegate methods
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    // A photo was taken/selected!
//    UIImage *imageTaken = [info objectForKey:UIImagePickerControllerOriginalImage];
//
//    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera)
//    {
//        // Save the image!
//        UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil);
//    }
    //
    //    //You can take the metadata here => info [UIImagePickerControllerMediaMetadata];
    //    UIImage* imageCropped = [info objectForKey:UIImagePickerControllerEditedImage];
    //
    //    CGFloat side = MIN(imageTaken.size.width, imageTaken.size.height);
    //    CGFloat x = imageTaken.size.width / 2 - side / 2;
    //    CGFloat y = imageTaken.size.height / 2 - side / 2;
    //
    //    CGRect cropRect = CGRectMake(x,y,320, 410);
    //    CGImageRef imageRef = CGImageCreateWithImageInRect([imageTaken CGImage], cropRect);
    //    UIImage *scaledOriginal = [UIImage imageWithCGImage:imageRef scale:imageCropped.scale orientation:imageTaken.imageOrientation];
    //    CGImageRelease(imageRef);

    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];

    [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        UIImage *preview = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];

        self.imageEditor.sourceImage = image;
        self.imageEditor.previewImage = preview;
        [self.imageEditor reset:NO];

        [picker presentViewController:self.imageEditor animated:YES completion:nil];
//        [picker pushViewController:self.imageEditor animated:YES];
        [picker setNavigationBarHidden:YES animated:NO];

    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to get asset from library");
    }];

//    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


@end
