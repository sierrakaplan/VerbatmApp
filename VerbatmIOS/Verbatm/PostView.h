
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//
//	Controls the presentation of a single article.
//	It simply manages laying out Pages as well as the playing/stoping of a page when it in/out of view.

#import "Channel.h"

#import <Parse/PFObject.h>
#import <UIKit/UIKit.h>

@protocol PostViewDelegate;

@interface PostView : UIView

@property (strong, nonatomic) Channel *listChannel; /* Channel currently reblogged in */
@property (strong, nonatomic) Channel *postChannel; /* Original channel posted to */
@property (strong, nonatomic) PFObject* parsePostChannelActivityObject;

@property (nonatomic) id<PostViewDelegate> delegate;

// stores pov info associated with this view
-(instancetype)initWithFrame:(CGRect)frame andPostChannelActivityObject:(PFObject*) postObject
					   small:(BOOL) small;

// Displays post from an array of PageViewingExperiences
-(void) renderPageViews: (NSArray *) pages;

// Displays post from an array of page PFObjects
-(void) renderPostFromPageObjects: (NSArray *) pages;

-(void) clearPost;

//Displays creator and channel at the top
-(void) addCreatorInfo;

//called by presenter of the POVView with access to the postinformation
-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares
								numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage
									  startUp:(BOOL)up withDeleteButton: (BOOL)withDelete;

//Scrolls POV to a specific page
-(void) scrollToPageAtIndex:(NSInteger) pageIndex;

//informs the POV when it's visible
-(void) postOnScreen;

-(void) preparepostToBePresented;

-(void) postOffScreen;

// presents media only for the page on screen
-(void) presentMediaContent;

//moves the like share bar up and down to be above tab bar when tab bar is showing
-(void) shiftLikeShareBarDown:(BOOL) down;

@end

@protocol PostViewDelegate <NSObject>

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post;
-(void) channelSelected:(Channel *) channel;
-(void) deleteButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post reblogged: (BOOL)reblogged;

-(void) flagButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post;

@end

