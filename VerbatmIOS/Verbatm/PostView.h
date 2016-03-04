
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
//	Controls the presentation of a single article.
//	It simply manages laying out Pages as well as the playing/stoping of a page when it in/out of view.

#import "Channel.h"

#import <Parse/PFObject.h>
#import <UIKit/UIKit.h>

@protocol PostViewDelegate <NSObject>

-(void) likeButtonLiked: (BOOL)liked onPostObject: (PFObject*) post;
-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post;
@end

@interface PostView : UIView


@property (nonatomic) id <PostViewDelegate> delegate;

// stores pov info associated with this view
-(instancetype)initWithFrame:(CGRect)frame andPostParseObject:(PFObject*) povObject;

-(void) renderPages: (NSArray *) pages;

-(void) renderPostFromPages: (NSArray *) pages;

-(void) addCreatorInfoFromChannel:(Channel *) channel;

-(void) clearArticle;

//adds a down arrow to the cover photo
-(void) addDownArrowButton;

//Scrolls POV to a specific page
-(void) scrollToPageAtIndex:(NSInteger) pageIndex;

//informs the POV when it's visible
-(void) postOnScreen;

-(void) postOffScreen;

//called by presenter of the POVView with access to the postinformation
-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage startUp:(BOOL)up;

-(void) presentMediaContent;

//moves the 
-(void) shiftLikeShareBarDown:(BOOL) down;

@end
