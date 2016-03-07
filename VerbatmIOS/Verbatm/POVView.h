
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
//	Controls the presentation of a single article.
//	It simply manages laying out Pages as well as the playing/stoping of a page when it in/out of view.

#import "Channel.h"

#import "PovInfo.h"
#import <Parse/PFObject.h>

#import <UIKit/UIKit.h>

@protocol POVViewDelegate <NSObject>
// tells whether button was liked or unliked
-(void) likeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo;
-(void) shareOptionSelectedForParsePostObject: (PFObject* ) pov;
@end

@interface POVView : UIView

@property (strong, nonatomic) PFObject* parsePostObject;
@property (nonatomic) id <POVViewDelegate> delegate;

// stores pov info associated with this view
-(instancetype)initWithFrame:(CGRect)frame andPovParseObject:(PFObject*) povObject;

// pageIndex is int value
-(void) renderNextAve: (UIView*) ave withIndex: (NSNumber*) pageIndex; 

-(void) renderAVES: (NSMutableArray *) aves;

-(void) addCreatorInfoFromChannel:(Channel *) channel;


-(void) displayMediaOnCurrentAVE;
-(void) clearArticle;

// adds like button with delegate so that backend can be updated when the like
// button is pressed, and passes the povID since the delegate
// needs to pass this back
//-(void) addLikeButtonWithDelegate: (id<LikeButtonDelegate>) delegate;

//adds a down arrow to the cover photo
-(void)addDownArrowButton;

//Scrolls POV to a specific page
-(void) scrollToPageAtIndex:(NSInteger) pageIndex;

//presents array of pages when they are downloaded
-(void) renderPOVFromPages:(NSArray *) pages;

//informs the POV when it's visible
-(void) povOnScreen;
-(void) povOffScreen;
-(void)preparePOVToBePresented;

//called by presenter of the POVView with access to the postinformation
-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage startUp:(BOOL)up;
-(void)presentMediaContent;
//moves the 
-(void) shiftLikeShareBarDown:(BOOL) down;
@end
