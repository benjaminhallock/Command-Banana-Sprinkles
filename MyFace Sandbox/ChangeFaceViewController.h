

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HFImageEditorViewController.h"
#import "DemoImageEditor.h"

@interface ChangeFaceViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) UIImagePickerController *imagePicker;
@property DemoImageEditor *imageEditor;
@property(nonatomic,strong) ALAssetsLibrary *library;
@end
