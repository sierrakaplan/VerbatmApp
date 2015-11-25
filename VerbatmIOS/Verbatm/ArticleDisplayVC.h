//
//  ArticleDisplayVC.h
//  Verbatm
//
//  View controller that controls what happens when you tap an article
// 	Shows horizontal scroll view where each "page" in the scroll view is a POVView
// 	Controls loading
//

#import <UIKit/UIKit.h>
#import "PovInfo.h"
#import "POVLoadManager.h"
@class POVLoadManager;

@protocol ArticleDisplayVCDelegate <NSObject>

-(void) userLiked:(BOOL)liked POV:(PovInfo *)povInfo;

@end

@interface ArticleDisplayVC : UIViewController

@property (strong, nonatomic) id<ArticleDisplayVCDelegate> delegate;

//tells the article display what content to present
-(void) presentContentWithPOVType: (POVType) povType;

//Removes any content loaded (reverses loadStory)
-(void) cleanUp;

@end
