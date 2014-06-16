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

@end

@implementation MakeFaceViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;

    [self.imagePicker.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"template"]]];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

- (IBAction)onTakePhotoPressed:(id)sender
{
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}



- (IBAction)onUploadPhotoPressed:(id)sender
{
    [self presentViewController:self.imagePicker
                       animated:YES
                     completion:nil];
}


#pragma mark - Image Picker Controller delegate methods
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // A photo was taken/selected!
    UIImage *imageTaken = [info objectForKey:UIImagePickerControllerEditedImage];

    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // Save the image!
        UIImageWriteToSavedPhotosAlbum(imageTaken, nil, nil, nil);
    }

    //You can take the metadata here => info [UIImagePickerControllerMediaMetadata];
    UIImage* imageCropped;

    CGFloat side = MIN(imageTaken.size.width, imageTaken.size.height);
    CGFloat x = imageTaken.size.width / 2 - side / 2;
    CGFloat y = imageTaken.size.height / 2 - side / 2;

    CGRect cropRect = CGRectMake(x,y,320, 410);
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageTaken CGImage], cropRect);
    imageCropped = [UIImage imageWithCGImage:imageRef scale:imageCropped.scale orientation:imageTaken.imageOrientation];
    CGImageRelease(imageRef);

    self.makeFaceImageView.image = imageCropped;

    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


@end
