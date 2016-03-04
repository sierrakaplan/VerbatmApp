//
//  POVLikeAndShareBar.h
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

@protocol PostLikeAndShareBarProtocol <NSObject>

-(void) shareButtonPressed;
-(void) likeButtonPressed;
-(void) showWhoLikesThePost;
-(void) showwhoHasSharedThePost;

@end

@interface PostLikeAndShareBar : UIView

-(instancetype) initWithFrame:(CGRect)frame numberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage;

-(void)setPageNumber:(NSNumber *) pageNumber;

@property (nonatomic) id <PostLikeAndShareBarProtocol> delegate;

@end
