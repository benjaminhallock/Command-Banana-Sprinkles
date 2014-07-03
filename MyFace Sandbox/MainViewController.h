
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DemoImageEditor.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) UIImagePickerController *imagePicker;
@property DemoImageEditor *imageEditor;
@property(nonatomic,strong) ALAssetsLibrary *library;
@end
