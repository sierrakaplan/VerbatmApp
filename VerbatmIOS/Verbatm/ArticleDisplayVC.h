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

@class POVLoadManager;

@protocol ArticleDisplayVCDelegate <NSObject>

-(void) userLiked:(BOOL)liked POV:(PovInfo *)povInfo;

@end

@interface ArticleDisplayVC : UIViewController

@property (strong, nonatomic) id<ArticleDisplayVCDelegate> delegate;

//Tells the VC to display story at that index from that load manager
//And gives it a reference to the load manager so that it can load previous
// and following stories
-(void) loadStoryAtIndex: (NSInteger) index fromLoadManager: (POVLoadManager*) loadManager;

//Removes any content loaded (reverses loadStory)
-(void) cleanUp;

@end
