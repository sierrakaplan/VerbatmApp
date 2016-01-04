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

@protocol POVLikeAndShareBarProtocol <NSObject>

-(void)shareButtonPressed;
-(void)likeButtonPressed;
-(void)showWhoLikesThePOV;//the like numbers have been pressed
-(void)showwhoHasSharedThePOV;

@end


@interface POVLikeAndShareBar : UIView

-(instancetype) initWithFrame:(CGRect)frame numberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage;




















@end
