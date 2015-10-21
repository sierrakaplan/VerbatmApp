
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/* Controls the presentation of a single article. It simply manages laying out Pages as well as the playing/stoping of a page when it in/out of view.
 */

#import "PovInfo.h"
#import <UIKit/UIKit.h>

@protocol LikeButtonDelegate <NSObject>

// tells whether button was liked or unliked
-(void) likeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo;

@end

@interface POVView : UIView

// default initializer
-(instancetype)initWithFrame:(CGRect)frame;

// stores pov info associated with this view
-(instancetype)initWithFrame:(CGRect)frame andPOVInfo:(PovInfo*) povInfo;

// pageIndex is int value
-(void) renderNextAve: (UIView*) ave withIndex: (NSNumber*) pageIndex;

-(void) renderAVES: (NSMutableArray *) aves;

-(void) displayMediaOnCurrentAVE;
-(void) clearArticle;

// adds like button with delegate so that backend can be updated when the like
// button is pressed, and passes the povID since the delegate
// needs to pass this back
-(void) addLikeButtonWithDelegate: (id<LikeButtonDelegate>) delegate;

//adds a down arrow to the cover photo
-(void)addDownArrowButton;

@end
