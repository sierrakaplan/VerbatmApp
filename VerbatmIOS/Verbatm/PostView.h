
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

@property (nonatomic) BOOL inSmallMode;

@property (nonatomic, weak) id<PostViewDelegate> delegate;

// stores pov info associated with this view
-(instancetype)initWithFrame:(CGRect)frame andPostChannelActivityObject:(PFObject*) postObject
					   small:(BOOL) small andPageObjects:(NSArray*) pageObjects;

// Displays post from an array of PageViewingExperiences
-(void) displayPageViews: (NSArray *) pages;


-(void) clearPost;

//Displays creator and channel at the top
-(void) addCreatorInfo;

//called by presenter of the POVView with access to the postinformation
-(void)createLikeAndShareBarWithNumberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfComments:(NSNumber *) numComments
                                numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage
                                      startUp:(BOOL)up withDeleteButton: (BOOL)withDelete;

//Scrolls POV to a specific page
-(void) scrollToPageAtIndex:(NSInteger) pageIndex;

//informs the POV when it's visible
-(void) postOnScreen;

-(void) postAlmostOnScreen;

-(void) postOffScreen;

-(void) muteAllVideos:(BOOL) shouldMute;

//moves the like share bar up and down to be above tab bar when tab bar is showing

-(void)showPageUpIndicator;
-(void)prepareForScreenShot;

-(void)checkIfUserHasLikedThePost;
-(void)commentButtonPressed;

-(void)likeButtonPressed;

-(void)shareButtonPressed;
@end

@protocol PostViewDelegate <NSObject>

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post;
-(void) channelSelected:(Channel *) channel;
-(void) deleteButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post reblogged: (BOOL)reblogged;
-(void) flagButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post;
-(void) showWhoLikesThePost:(PFObject *) post;
-(void)removePostViewSelected;
-(void)presentSmallLikeButton;
-(void)updateSmallLikeButton:(BOOL)isLiked;
-(void)startLikeButtonAsLiked:(BOOL)isLiked;
-(void)showWhoCommentedOnPost:(PFObject *) post;
@end

