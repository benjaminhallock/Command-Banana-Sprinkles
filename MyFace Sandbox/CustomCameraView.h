//
//  AddRecommendationViewController.h
//  Recommend
//

#import "CustomCameraView.h"
#import <UIKit/UIKit.h>


#pragma mark - DELEGATE
@protocol CustomCameraDelegate <NSObject>

-(void)sendBackPicture:(UIImage *)image;

@end

@interface CustomCameraView : UIViewController

@property(nonatomic,assign)id delegate;

-(id)initWithPopUp:(BOOL)popup;

-(void)setPopUp;

@property BOOL isReturningFromBackButton;

@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;

@property (atomic) BOOL isPoppingUp;

@property UIImagePickerController *picker;

@end
