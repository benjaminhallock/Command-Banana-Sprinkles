//
//  MakeFaceViewController.m
//  MyFace
//
//  Created by tbredemeier on 6/16/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import "MakeFaceViewController.h"
#import "Photos.h"
#import "AppDelegate.h"
@interface MakeFaceViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *makeFaceImageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIScrollView *makeFaceScrollView;
@property DemoImageEditor *imageEditor;
@property(nonatomic,strong) ALAssetsLibrary *library;
@end

@implementation MakeFaceViewController
- (void)viewDidLoad
{
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.textField.delegate = self;
    [super viewDidLoad];
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
                                      } else {
                                          self.makeFaceImageView.image = editedImage;
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
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        self.textField.frame = CGRectMake(0.0f, 320.0f, 320.0f, 30.0f);
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
         self.textField.frame = CGRectMake(0.0f, 484.0f, 320.0f, 30.0f);
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)onUploadPhotoPressed:(id)sender
{
    if (self.makeFaceImageView.image != nil && self.textField.text.length != nil) {

    UIImage *image = self.makeFaceImageView.image;

    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setValue:UIImagePNGRepresentation(image) forKey:@"image"];
    [newManagedObject setValue:self.textField.text forKey:@"name"];
    [newManagedObject setValue:@NO forKey:@"selected"];
    [self.managedObjectContext save:nil];

    //Save to core data;
    [UIView  animateWithDuration:1.0 animations:^{
        self.textField.alpha = 1;
        self.makeFaceImageView.alpha = 1;
        self.makeFaceImageView.image = nil;
                self.textField.text = @"";
        self.makeFaceImageView.alpha = 0;
                self.textField.alpha = 0;
        self.makeFaceImageView.alpha = 1;
                self.textField.alpha = 1;
    }];

    }
}

-(IBAction)unwind:(UIStoryboardSegue *)sender {
    
}

#pragma mark - Image Picker Controller delegate methods
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];

    [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        UIImage *preview = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];

        self.imageEditor.sourceImage = image;
        self.imageEditor.previewImage = preview;
        [self.imageEditor reset:NO];

//        [picker presentViewController:self.imageEditor animated:YES completion:nil];
        [picker pushViewController:self.imageEditor animated:YES];
        [picker setNavigationBarHidden:YES animated:NO];

    } failureBlock:^(NSError *error) {
        NSLog(@"Failed to get asset from library");
    }];

//    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


@end
