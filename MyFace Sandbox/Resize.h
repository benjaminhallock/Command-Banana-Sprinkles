//
//  Resize.h
//  MyFace
//
//  Created by benjaminhallock@gmail.com on 6/18/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Resize : UIImage
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end
