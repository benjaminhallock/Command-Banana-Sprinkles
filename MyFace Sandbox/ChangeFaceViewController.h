

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HFImageEditorViewController.h"
#import "DemoImageEditor.h"

@interface ChangeFaceViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) DemoImageEditor *imageEditor;
@property (strong, nonatomic) ALAssetsLibrary *library;
@end
