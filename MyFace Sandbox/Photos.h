//
//  Photos.h
//  myFaceB
//
//  Created by benjaminhallock@gmail.com on 9/11/14.
//  Copyright (c) 2014 ben Academy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photos : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * selected;

@end
