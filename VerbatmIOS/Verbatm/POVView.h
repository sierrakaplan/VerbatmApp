
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/* Controls the presentation of a single article. It simply manages laying out Pages as well as the playing/stoping of a page when it in/out of view.
 */

#import <UIKit/UIKit.h>

@protocol LikeButtonDelegate <NSObject>

// tells whether button was liked or unliked
-(void) likeButtonLiked: (BOOL)liked onPOVWithID: (NSNumber*) povID;
@end

@interface POVView : UIView

@property (strong, nonatomic) NSMutableArray * pageAves;

// Takes array of AVES (pages as views)
-(void) renderAVES: (NSMutableArray *) aves;

-(void) renderNextAve: (UIView*) ave;

-(void) displayMediaOnCurrentAVE;
-(void) clearArticle;

// adds like button with delegate so that backend can be updated when the like
// button is pressed, and passes the povID since the delegate
// needs to pass this back
-(void) addLikeButtonWithDelegate: (id<LikeButtonDelegate>) delegate andSetPOVID: (NSNumber*) povID;

//adds a down arrow to the cover photo
-(void)addDownArrowButton;

@end
