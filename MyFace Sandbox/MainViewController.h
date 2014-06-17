//
//  ViewController.h
//  MyFace Sandbox
//
//  Created by tbredemeier on 6/13/14.
//  Copyright (c) 2014 Mobile Makers Academy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
