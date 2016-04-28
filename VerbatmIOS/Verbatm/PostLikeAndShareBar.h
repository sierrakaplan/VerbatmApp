
//
//  PostLikeAndShareBar.h
//  Verbatm
//
//  Created by Iain Usiri on 12/29/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Presents the like button and share button as well as the number of likes and shares.
 It also shows the page that we are on on the POV
 */

typedef enum BarActivityOptions{
	Like = 0,
	Share = 1,
} ActivityOptions;

@protocol PostLikeAndShareBarProtocol <NSObject>

//if the activity is a like the positive says if it's a like or unlike
//like == positive , unlike == !positive
-(void)userAction:(ActivityOptions) action isPositive:(BOOL) positive;
-(void)showWhoLikesThePost;//the like numbers have been pressed
-(void)showwhoHasSharedThePost;
-(void)muteButtonSelected:(BOOL)shouldMute;
-(void)deleteButtonPressed;

-(void)flagButtonPressed;


@end


@interface PostLikeAndShareBar : UIView

-(instancetype) initWithFrame:(CGRect)frame numberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage;

-(void)presentMuteButton:(BOOL) shouldPresent;
-(void)shouldStartPostAsLiked:(BOOL) postLiked;

//if it's the current user's post we add a delete icon
//if it's another user's post we create a flag
-(void)createDeleteButton;
-(void)createFlagButton;

@property (nonatomic, weak) id <PostLikeAndShareBarProtocol> delegate;

@end
