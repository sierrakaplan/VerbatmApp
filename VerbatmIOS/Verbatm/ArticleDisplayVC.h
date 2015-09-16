//
//  ArticleDisplayVC.h
//  Verbatm
//
//  View controller that controls what happens when you tap an article
// 	Shows horizontal scroll view where each "page" in the scroll view is a POVView
// 	Controls loading
//

#import <UIKit/UIKit.h>

@class POVLoadManager;

@interface ArticleDisplayVC : UIViewController

//Tells the VC to display story at that index from that load manager
//And gives it a reference to the load manager so that it can load previous
// and following stories
-(void) loadStory: (NSInteger) index fromLoadManager: (POVLoadManager*) loadManager;

//Removes any content loaded (reverses loadStory)
-(void) cleanUp;

@end
