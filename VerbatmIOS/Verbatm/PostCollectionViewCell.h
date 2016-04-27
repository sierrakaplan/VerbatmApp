//
//  postHolderCollecitonRV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
#import "PostView.h"

@protocol PostCollectionViewCellDelegate <NSObject>

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post;
-(void) channelSelected:(Channel *) channel;
-(void) deleteButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post andPostChannelActivityObj:(PFObject*)pfActivityObj
							 reblogged:(BOOL)reblogged;
-(void) flagButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post;

@end

@interface PostCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) id<PostCollectionViewCellDelegate> cellDelegate;
@property (nonatomic, readonly) PostView *currentPostView;
@property (nonatomic, readonly) PFObject *currentPostActivityObject;

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete;

-(void) shiftLikeShareBarDown:(BOOL) down;

-(void) almostOnScreen;
-(void) onScreen;
-(void) offScreen;

-(void) clearViews;


@end
