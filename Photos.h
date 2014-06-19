//
//  Photos.h
//  myFaceB
//
//  Created by benjaminhallock@gmail.com on 6/19/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photos : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSData * thumbnail;

@end
