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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSave;
@property(nonatomic,strong) ALAssetsLibrary *library;
@end

@implementation MakeFaceViewController


-(void)viewDidAppear:(BOOL)animated {

    self.editing = !self.editing;

    if (self.editing == YES) {
    [self onTakePhotoPressed:nil];
    } else {
        [self onUploadPhotoPressed:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

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

    if (self.makeFaceImageView.image) {
        self.buttonSave.enabled = YES;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        self.buttonSave.enabled = NO;
    }
}

- (void)viewDidLoad
{
    }

//-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.makeFaceImageView;
//}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTakePhotoPressed:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(IBAction)onGalleryPressed:(UIButton *)sender{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        self.textField.frame = CGRectMake(0.0f, self.textField.frame.origin.y - 160, 320.0f, 50.0f);
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        self.textField.frame = CGRectMake(0.0f, self.textField.frame.origin.y + 160, 320.0f, 50.0f);
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([self.textField.text  isEqual: @""]) {
        self.textField.text = @"name this face";
    }
    return YES;
}

- (IBAction)onUploadPhotoPressed:(id)sender
{
    if (self.makeFaceImageView.image != nil) {

        if ([self.textField.text isEqualToString:@"name this face"] || [self.textField.text isEqualToString:@""]) {
            self.textField.text = @"Joe Shmoe";
        }

        UIImage *image = self.makeFaceImageView.image;

        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
        [newManagedObject setValue:UIImagePNGRepresentation(image) forKey:@"image"];
        [newManagedObject setValue:self.textField.text forKey:@"name"];
        [newManagedObject setValue:@YES forKey:@"selected"];
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
            [self.textField resignFirstResponder];
            [self dismissViewControllerAnimated:YES completion:nil];
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
