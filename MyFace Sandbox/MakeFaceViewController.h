//
//  MakeFaceViewController.h
//  MyFace
//
//  Created by tbredemeier on 6/16/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DemoImageEditor.h"

@interface MakeFaceViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIScrollViewDelegate>

@property UIImagePickerController *imagePicker;

@end
